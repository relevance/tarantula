require File.join(File.dirname(__FILE__), "../..", "test_helper.rb")
require 'relevance/core_extensions/test_case'

describe "TestCase extensions" do
  it "can create the crawler" do 
    RailsIntegrationProxy.stubs(:rails_root).returns("STUB_RAILS_ROOT")
    tarantula_crawler(stub_everything)
  end
  
  it "can crawl" do
    (crawler = mock).expects(:crawl).with("/foo")
    expects(:tarantula_crawler).returns(crawler)
    tarantula_crawl(:integration_test_stub, :url => "/foo")
  end
end