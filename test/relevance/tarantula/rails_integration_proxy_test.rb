require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::RailsIntegrationProxy" do
  %w{get post}.each do |http_method|
    it "can #{http_method}" do
      @rip = Relevance::Tarantula::RailsIntegrationProxy.new(stub)
      @response = stub({:code => :foo})
      @rip.integration_test = stub_everything(:response => @response)
      @rip.send(http_method, "/url").should.be @response
    end
  end
  
  it "adds a response accessor to its delegate rails integration test" do
    o = Object.new
    Relevance::Tarantula::RailsIntegrationProxy.new(o)
    o.methods(false).sort.should == %w{response response=}
  end

end

describe "Relevance::Tarantula::RailsIntegrationProxy 404 handling" do
  before do
    @rip = Relevance::Tarantula::RailsIntegrationProxy.new(stub)
    @rip.stubs(:rails_root).returns("faux_rails_root")
    @response = stub_everything({:code => "404", :headers => {}})
    File.stubs(:exist?).returns(true)
  end
  
  it "ignores 404s for known static binary types" do
    File.expects(:extension).returns("pdf")
    @rip.expects(:log).with("Skipping /url (for now)")
    @rip.check_for_static_version_of_404s("/url", @response)
  end
  
  it "replaces 404s with 200s, pulling content from public, for known text types" do
    File.expects(:extension).returns("html")
    @rip.expects(:static_content_file).with("/url").returns("File body")
    @rip.check_for_static_version_of_404s("/url", @response)
    @response.headers.should == {"type" => "text/html"}
  end
  
  it "logs and skips types we haven't dealt with yet" do
    File.expects(:extension).returns("whizzy")
    @rip.expects(:log).with("Skipping unknown type /url")
    @rip.check_for_static_version_of_404s("/url", @response)
  end
  
  it "can find static content relative to rails root" do
    @rip.static_content_path("foo").should == File.expand_path("faux_rails_root/public/foo")
  end
  
  it "can read static content relative to rails root" do
    File.expects(:read).with(@rip.static_content_path("foo"))
    @rip.static_content_file("foo")
  end
end
