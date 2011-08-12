require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb"))

describe Relevance::Tarantula::Crawler do
  
  describe "transform_url" do

    before { @crawler = Relevance::Tarantula::Crawler.new }

    it "de-obfuscates unicode obfuscated urls" do
      obfuscated_mailto = "&#109;&#97;&#105;&#108;&#116;&#111;&#58;"
      @crawler.transform_url(obfuscated_mailto).should == "mailto:"
    end
  
    it "strips the trailing name portion of a link" do
      @crawler.transform_url('http://host/path#name').should == 'http://host/path'
    end
  end
  
  
  describe "log grabbing" do

    it "returns nil if no grabber is specified" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.grab_log!.should == nil
    end

    it "returns grabber.grab if grabber is specified" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.log_grabber = stub(:grab! => "fake log entry")
      crawler.grab_log!.should == "fake log entry"
    end
    
  end
  
  describe "interrupt" do
    
    it 'catches interruption and writes the partial report' do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.stubs(:queue_link)
      crawler.stubs(:do_crawl).raises(Interrupt)
      crawler.expects(:report_results)
      $stderr.expects(:puts).with("CTRL-C")
      crawler.crawl
    end
    
  end
  
  describe 'handle_form_results' do
    
    it 'captures the result values (bugfix)' do
      response = stub_everything
      result_args = {:url => :action_stub, 
                      :data => 'nil', 
                      :response => response, 
                      :referrer => :action_stub, 
                      :log => nil, 
                      :method => :stub_method,
                      :test_name => nil}
      result = Relevance::Tarantula::Result.new(result_args)
      Relevance::Tarantula::Result.expects(:new).with(result_args).returns(result)
      crawler = Relevance::Tarantula::Crawler.new
      crawler.handle_form_results(stub_everything(:method => :stub_method, :action => :action_stub), 
                                  response)
    end
    
  end
  
  describe "crawl" do
    
    it 'queues the first url, does crawl, and then reports results' do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.expects(:queue_link).with("/foobar")
      crawler.expects(:do_crawl)
      crawler.expects(:report_results)
      crawler.crawl("/foobar")
    end

    it 'reports results even if the crawl fails' do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.expects(:do_crawl).raises(RuntimeError)
      crawler.expects(:report_results)
      lambda {crawler.crawl('/')}.should raise_error(RuntimeError)
    end
    
  end
  
  describe "queueing" do

    it 'queues and remembers links' do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.expects(:transform_url).with("/url").returns("/transformed").at_least_once
      crawler.queue_link("/url")
      # TODO not sure this is the best way to test this anymore; relying on result of transform in both actual and expected
      crawler.crawl_queue.should == [make_link("/url", crawler)]
      crawler.links_queued.should == Set.new([make_link("/url", crawler)])
    end

    it 'queues and remembers forms' do
      crawler = Relevance::Tarantula::Crawler.new
      form = Hpricot('<form action="/action" method="post"/>').at('form')
      signature = Relevance::Tarantula::FormSubmission.new(make_form(form)).signature
      crawler.queue_form(form)
      crawler.crawl_queue.size.should == 1
      crawler.form_signatures_queued.should == Set.new([signature])
    end

    it "passes link, self, and referrer when creating Link objects" do
      crawler = Relevance::Tarantula::Crawler.new
      Relevance::Tarantula::Link.expects(:new).with('/url', crawler, '/some-referrer')
      crawler.stubs(:should_skip_link?)
      crawler.queue_link('/url', '/some-referrer')
    end
    
  end
  
  describe "crawling" do
    before do
      @form = Hpricot('<form action="/action" method="post"/>').at('form')
    end
    
    it "does two things with each link: crawl and blip" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.proxy = stub
      crawler.crawl_queue = links = [make_link("/foo1", crawler), make_link("/foo2", crawler)]
      
      links.each{|link| link.expects(:crawl)}
      crawler.expects(:blip).times(2)
      
      crawler.crawl_the_queue
      crawler.crawl_queue.should == []
    end

    it "invokes queued forms, logs responses, and calls handlers" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.crawl_queue << Relevance::Tarantula::FormSubmission.new(make_form(@form, crawler))
      crawler.expects(:submit).returns(stub(:code => "200"))
      crawler.expects(:blip)
      crawler.crawl_the_queue
    end
    
    # TODO this is the same as "resets to the initial links/forms ..." and doesn't appear to test anything related to a timeout.
    it "breaks out early if a timeout is set"

    it "resets to the initial links/forms on subsequent crawls when times_to_crawl > 1" do
      crawler = Relevance::Tarantula::Crawler.new
      stub_puts_and_print(crawler)
      response = stub(:code => "200")
      crawler.queue_link('/foo')
      crawler.expects(:follow).returns(response).times(4) # (stub and "/") * 2
      crawler.queue_form(@form)
      crawler.expects(:submit).returns(response).times(2)
      crawler.expects(:blip).times(6)
      crawler.times_to_crawl = 2
      crawler.crawl
    end
    
  end
  
  describe "report_results" do
    it "prints a final summary line" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.stubs(:generate_reports)
      crawler.expects(:total_links_count).returns(42)
      crawler.expects(:puts).with("Crawled 42 links and forms.")
      crawler.report_results
    end
    
    it "delegates to generate_reports" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.stubs(:puts)
      crawler.expects(:generate_reports)
      crawler.report_results
    end
    
  end
  
  describe "blip" do

    it "blips the current progress if !verbose" do
      $stdout.stubs(:tty?).returns(true)
      crawler = Relevance::Tarantula::Crawler.new
      crawler.stubs(:verbose).returns false
      crawler.stubs(:timeout_if_too_long)
      crawler.expects(:print).with("\r 0 of 0 links completed               ")
      crawler.blip
    end
    
    it "suppresses the blip message if not writing to a tty" do
      $stdout.stubs(:tty?).returns(false)
      crawler = Relevance::Tarantula::Crawler.new
      crawler.stubs(:verbose).returns false
      crawler.stubs(:timeout_if_too_long)
      crawler.expects(:print).never
      crawler.blip
    end
    
    it "blips nothing if verbose" do
      $stdout.stubs(:tty?).returns(true)
      crawler = Relevance::Tarantula::Crawler.new
      crawler.stubs(:verbose).returns true
      crawler.expects(:print).never
      crawler.blip
    end
    
  end
  
  describe "finished?" do

    it "is finished when the links and forms are crawled" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.finished?.should == true
    end

    it "isn't finished when links remain" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.crawl_queue = [:stub_link]
      crawler.finished?.should == false
    end

    it "isn't finished when forms remain" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.crawl_queue = [:stub_form]
      crawler.finished?.should == false
    end
    
  end

  it "crawls links and forms again and again until finished?==true" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:finished?).times(3).returns(false, false, true)
    crawler.expects(:crawl_the_queue).times(2)
    crawler.do_crawl(1)
  end
  
  it "asks each reporter to write its report in report_dir" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.stubs(:report_dir).returns(test_output_dir)
    reporter = stub_everything
    reporter.expects(:report)
    reporter.expects(:finish_report)
    crawler.reporters = [reporter]
    crawler.save_result stub(:code => "404", :url => "/uh-oh")
    crawler.generate_reports
  end
  
  it "builds a report dir relative to rails root" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.expects(:rails_root).returns("faux_rails_root")
    crawler.report_dir.should == "faux_rails_root/tmp/tarantula"
  end
  
  it "skips links that are already queued" do
    crawler = Relevance::Tarantula::Crawler.new
    crawler.should_skip_link?(make_link("/foo")).should == false
    crawler.queue_link("/foo").should == make_link("/foo")
    crawler.should_skip_link?(make_link("/foo")).should == true
  end
  
  describe "link skipping" do

    before { @crawler = Relevance::Tarantula::Crawler.new }
    
    it "skips links that are too long" do
      @crawler.should_skip_link?(make_link("/foo")).should == false
      @crawler.max_url_length = 2
      @crawler.expects(:log).with("Skipping long url /foo")
      @crawler.should_skip_link?(make_link("/foo")).should == true
    end
  
    it "skips outbound links (those that begin with http)" do
      @crawler.expects(:log).with("Skipping http-anything")
      @crawler.should_skip_link?(make_link("http-anything")).should == true
    end

    it "skips javascript links (those that begin with javascript)" do
      @crawler.expects(:log).with("Skipping javascript-anything")
      @crawler.should_skip_link?(make_link("javascript-anything")).should == true
    end

    it "skips mailto links (those that begin with http)" do
      @crawler.expects(:log).with("Skipping mailto-anything")
      @crawler.should_skip_link?(make_link("mailto-anything")).should == true
    end
  
    it 'skips blank links' do
      @crawler.queue_link(nil)
      @crawler.crawl_queue.should == []
      @crawler.queue_link("")
      @crawler.crawl_queue.should == []
    end
  
    it "logs and skips links that match a pattern" do
      @crawler.expects(:log).with("Skipping /the-red-button")
      @crawler.skip_uri_patterns << /red-button/
      @crawler.queue_link("/blue-button").should == make_link("/blue-button")
      @crawler.queue_link("/the-red-button").should == nil
    end   
  
    it "logs and skips form submissions that match a pattern" do
      @crawler.expects(:log).with("Skipping /reset-password-form")
      @crawler.skip_uri_patterns << /reset-password/             
      fs = stub_everything(:action => "/reset-password-form")
      @crawler.should_skip_form_submission?(fs).should == true
    end
  end
  
  describe "allow_nnn_for" do

    it "installs result as a response_code_handler" do
      crawler = Relevance::Tarantula::Crawler.new
      crawler.response_code_handler.should == Relevance::Tarantula::Result
    end

    it "delegates to the response_code_handler" do
      crawler = Relevance::Tarantula::Crawler.new
      (response_code_handler = mock).expects(:allow_404_for).with(:stub)
      crawler.response_code_handler = response_code_handler
      crawler.allow_404_for(:stub)
    end

    it "chains up to super for method_missing" do
      crawler = Relevance::Tarantula::Crawler.new
      lambda{crawler.foo}.should raise_error(NoMethodError)
    end
    
  end
  
  describe "timeouts" do

    it "sets start and end times for a single crawl" do
      start_time = Time.parse("March 1st, 2008 10:00am")
      end_time = Time.parse("March 1st, 2008 10:10am")
      Time.stubs(:now).returns(start_time, end_time)

      crawler = Relevance::Tarantula::Crawler.new
      stub_puts_and_print(crawler)
      crawler.proxy = stub_everything(:get => response = stub(:code => "200"))
      crawler.crawl
      crawler.crawl_start_times.first.should == start_time
      crawler.crawl_end_times.first.should == end_time
    end
    
    it "has elasped time for a crawl" do
      start_time = Time.parse("March 1st, 2008 10:00am")
      elasped_time_check = Time.parse("March 1st, 2008, 10:10:00am")
      Time.stubs(:now).returns(start_time, elasped_time_check)

      crawler = Relevance::Tarantula::Crawler.new
      stub_puts_and_print(crawler)
      crawler.proxy = stub_everything(:get => response = stub(:code => "200"))
      crawler.crawl
      crawler.elasped_time_for_pass(0).should == 600.seconds
    end
    
    it "raises out of the crawl if elasped time is greater then the crawl timeout" do
      start_time = Time.parse("March 1st, 2008 10:00am")
      elasped_time_check = Time.parse("March 1st, 2008, 10:35:00am")
      Time.stubs(:now).returns(start_time, elasped_time_check)

      crawler = Relevance::Tarantula::Crawler.new
      crawler.crawl_timeout = 5.minutes
      
      crawler.crawl_queue = [stub(:href => "/foo1", :method => :get), stub(:href => "/foo2", :method => :get)]
      crawler.proxy = stub
      crawler.proxy.stubs(:get).returns(response = stub(:code => "200"))
      
      stub_puts_and_print(crawler)
      lambda {
        crawler.do_crawl(0)
      }.should raise_error
    end
    
  end
  
end