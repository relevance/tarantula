require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::Crawler rails_integration_test" do
  it "strips leading hostname from link urls" do
    Crawler.any_instance.stubs(:crawl)
    RailsIntegrationProxy.stubs(:new)
    crawler = Crawler.rails_integration_test(stub(:host => "foo.com"))
    crawler.transform_url("http://foo.com/path").should == "/path"
    crawler.transform_url("http://bar.com/path").should == "http://bar.com/path"
  end
end

describe 'Relevance::Tarantula::Crawler#tranform_url' do
  it "strips the trailing name portion of a link" do
    crawler = Crawler.new
    crawler.transform_url('http://host/path#name').should == 'http://host/path'
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

describe 'Relevance::Tarantula::Crawler#crawl_queued_forms' do
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
  
  it "skips outbound links (those that begin with http)" do
    crawler = Crawler.new
    crawler.should_skip_link?("http-anything").should == true
  end

  it "skips mailto links (those that begin with http)" do
    crawler = Crawler.new
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

