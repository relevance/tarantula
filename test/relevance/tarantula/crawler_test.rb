require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe 'Relevance::Tarantula::Crawler#transform_url' do
  before {@crawler = Crawler.new}
  it "de-obfuscates unicode obfuscated urls" do
    obfuscated_mailto = "&#109;&#97;&#105;&#108;&#116;&#111;&#58;"
    @crawler.transform_url(obfuscated_mailto).should == "mailto:"
  end
  
  it "strips the trailing name portion of a link" do
    @crawler.transform_url('http://host/path#name').should == 'http://host/path'
  end
end

describe 'Relevance::Tarantula::Crawler log grabbing' do
  it "returns nil if no grabber is specified" do
    crawler = Crawler.new
    crawler.grab_log!.should == nil
  end
  
  it "returns grabber.grab if grabber is specified" do
    crawler = Crawler.new
    crawler.log_grabber = stub(:grab! => "fake log entry")
    crawler.grab_log!.should == "fake log entry"
  end
end

describe 'Relevance::Tarantula::Crawler interruption' do
  it 'catches interruption and writes the partial report' do
    crawler = Crawler.new
    crawler.stubs(:queue_link)
    crawler.stubs(:do_crawl).raises(Interrupt)
    crawler.expects(:report_results)
    $stderr.expects(:puts).with("CTRL-C")
    crawler.crawl
  end
end

describe 'Relevance::Tarantula::Crawler handle_form_results' do
  it 'captures the result values (bugfix)' do
    response = stub_everything
    result_args = {:url => :action_stub, 
                    :data => 'nil', 
                    :response => response, 
                    :referrer => :action_stub, 
                    :log => nil, 
                    :method => :stub_method}
    result = Result.new(result_args)
    Result.expects(:new).with(result_args).returns(result)
    crawler = Crawler.new
    crawler.handle_form_results(stub_everything(:method => :stub_method, :action => :action_stub), 
                                response)
  end
end

describe 'Relevance::Tarantula::Crawler#crawl' do
  it 'queues the first url, does crawl, and then reports results' do
    crawler = Crawler.new
    crawler.expects(:queue_link).with("/foobar")
    crawler.expects(:do_crawl)
    crawler.expects(:report_results)
    crawler.crawl("/foobar")
  end
  
  it 'reports results even if the crawl fails' do
    crawler = Crawler.new
    crawler.expects(:do_crawl).raises(RuntimeError)
    crawler.expects(:report_results)
    lambda {crawler.crawl('/')}.should.raise(RuntimeError)
  end
end

describe 'Relevance::Tarantula::Crawler queuing' do
  it 'queues and remembers links' do
    crawler = Crawler.new
    crawler.expects(:transform_url).with("/url").returns("/transformed")
    crawler.queue_link("/url")
    crawler.links_to_crawl.should == ["/transformed"]
    crawler.links_queued.should == Set.new("/transformed")
  end
  
  it 'queues and remembers forms' do
    crawler = Crawler.new
    form = HTML::Document.new('<form action="/action" method="post"/>').find(:tag =>'form')
    signature = FormSubmission.new(Form.new(form)).signature
    crawler.queue_form(form)
    crawler.forms_to_crawl.size.should == 1
    crawler.form_signatures_queued.should == Set.new([signature])
  end
  
  it 'remembers link referrer if there is one' do
    crawler = Crawler.new
    crawler.queue_link("/url", "/some-referrer")
    crawler.referrers.should == {"/url" => "/some-referrer"}
  end
  
end

describe 'Relevance::Tarantula::Crawler#report_results' do
  it "delegates to generate_reports then report_to_console" do
    crawler = Crawler.new
    crawler.expects(:report_dir)
    crawler.expects(:puts)
    crawler.expects(:generate_reports)
    crawler.expects(:report_to_console)
    crawler.report_results
  end
end

describe 'Relevance::Tarantula::Crawler#crawling' do

  it "converts ActiveRecord::RecordNotFound into a 404" do
    (proxy = stub_everything).expects(:send).raises(ActiveRecord::RecordNotFound)
    crawler = Crawler.new
    crawler.proxy = proxy
    response = crawler.crawl_form stub_everything(:method => nil)
    response.code.should == "404"
    response.content_type.should == "text/plain"
    response.body.should == "ActiveRecord::RecordNotFound"
  end

  it "does four things with each link: get, log, handle, and blip" do
    crawler = Crawler.new
    crawler.proxy = stub
    response = stub(:code => "200")
    crawler.links_to_crawl = [:stub_1, :stub_2]
    crawler.proxy.expects(:get).returns(response).times(2)
    crawler.expects(:log).times(2)
    crawler.expects(:handle_link_results).times(2)
    crawler.expects(:blip).times(2)
    crawler.crawl_queued_links
    crawler.links_to_crawl.should == []
  end
    
  it "invokes queued forms, logs responses, and calls handlers" do
    crawler = Crawler.new
    crawler.forms_to_crawl << stub_everything(:method => "get", 
                                              :action => "/foo",
                                              :data => "some data",
                                              :to_s => "stub")
    crawler.proxy = stub_everything(:send => stub(:code => "200" ))
    crawler.expects(:log).with("Response 200 for stub")
    crawler.expects(:blip)
    crawler.crawl_queued_forms
  end
end

describe 'Crawler blip' do
  it "blips the current progress if !verbose" do
    crawler = Crawler.new
    crawler.stubs(:verbose).returns false
    crawler.expects(:print).with("\r 0 of 0 links completed               ")
    crawler.blip
  end
  it "blips nothing if verbose" do
    crawler = Crawler.new
    crawler.stubs(:verbose).returns true
    crawler.expects(:print).never
    crawler.blip
  end
end

describe 'Relevance::Tarantula::Crawler' do
  it "is finished when the links and forms are crawled" do
    crawler = Crawler.new
    crawler.finished?.should == true
  end

  it "isn't finished when links remain" do
    crawler = Crawler.new
    crawler.links_to_crawl = [:stub_link]
    crawler.finished?.should == false
  end

  it "isn't finished when links remain" do
    crawler = Crawler.new
    crawler.forms_to_crawl = [:stub_form]
    crawler.finished?.should == false
  end
  
  it "crawls links and forms again and again until finished?==true" do
    crawler = Crawler.new
    crawler.expects(:finished?).times(3).returns(false, false, true)
    crawler.expects(:crawl_queued_links).times(2)
    crawler.expects(:crawl_queued_forms).times(2)
    crawler.do_crawl
  end
  
  it "reports errors to stderr and then raises" do
    crawler = Crawler.new
    crawler.failures << stub(:code => "404", :url => "/uh-oh")
    $stderr.expects(:puts).with("****** FAILURES")
    $stderr.expects(:puts).with("404: /uh-oh")
    lambda {crawler.report_to_console}.should.raise RuntimeError
  end
  
  it "asks each reporter to write its report in report_dir" do
    crawler = Crawler.new
    crawler.failures << stub(:code => "404", :url => "/uh-oh")
    crawler.stubs(:report_dir).returns(test_output_dir)
    reporter = stub_everything
    reporter.expects(:report)
    crawler.reporters = [reporter]
    crawler.generate_reports
  end
  
  it "builds a report dir relative to rails root" do
    crawler = Crawler.new
    crawler.expects(:rails_root).returns("faux_rails_root")
    crawler.report_dir.should == "faux_rails_root/tmp/tarantula"
  end
  
  it "skips links that are already queued" do
    crawler = Crawler.new
    crawler.should_skip_link?("/foo").should == false
    crawler.queue_link("/foo").should == "/foo"
    crawler.should_skip_link?("/foo").should == true
  end
  
  it "skips links that are too long" do
    crawler = Crawler.new
    crawler.should_skip_link?("/foo").should == false
    crawler.max_url_length = 2
    crawler.expects(:log).with("Skipping long url /foo")
    crawler.should_skip_link?("/foo").should == true
  end
  
  it "skips outbound links (those that begin with http)" do
    crawler = Crawler.new
    crawler.expects(:log).with("Skipping http-anything")
    crawler.should_skip_link?("http-anything").should == true
  end

  it "skips mailto links (those that begin with http)" do
    crawler = Crawler.new
    crawler.expects(:log).with("Skipping mailto-anything")
    crawler.should_skip_link?("mailto-anything").should == true
  end
  
  it 'skips blank links' do
    crawler = Crawler.new
    crawler.queue_link(nil)
    crawler.links_to_crawl.should == []
    crawler.queue_link("")
    crawler.links_to_crawl.should == []
  end
  
  it "logs and skips links that match a pattern" do
    crawler = Crawler.new
    crawler.expects(:log).with("Skipping /the-red-button")
    crawler.skip_uri_patterns << /red-button/
    crawler.queue_link("/blue-button").should == "/blue-button"
    crawler.queue_link("/the-red-button").should == nil
  end
  
end

describe "allow_nnn_for" do
  it "installs result as a response_code_handler" do
    crawler = Crawler.new
    crawler.response_code_handler.should == Result
  end
  
  it "delegates to the response_code_handler" do
    crawler = Crawler.new
    (response_code_handler = mock).expects(:allow_404_for).with(:stub)
    crawler.response_code_handler = response_code_handler
    crawler.allow_404_for(:stub)
  end
  
  it "chains up to super for method_missing" do
    crawler = Crawler.new
    lambda{crawler.foo}.should.raise(NoMethodError)
  end
end