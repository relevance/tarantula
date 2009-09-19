require File.expand_path(File.join(File.dirname(__FILE__), "../..", "example_helper.rb"))

describe Relevance::Tarantula::Config do
  CrawlConfig = Relevance::Tarantula::Config::CrawlConfig
  
  before do
    @config = Object.new
    class <<@config; include(Relevance::Tarantula::Config); end
  end
  
  describe "crawl" do
    it "supplies appropriate default options to the crawl configurator if none are supplied" do
      CrawlConfig.expects(:new).
          with(:test_name => 'tarantula crawl', :default_root_page => '/').
          returns(stub_everything)
      @config.crawl
    end
    
    it "passes a supplied test name to the crawl configurator" do
      CrawlConfig.expects(:new).
          with(:test_name => 'some name', :default_root_page => '/').
          returns(stub_everything)
      @config.crawl('some name')
    end
    
    it "yields the crawl configurator to a passed block" do
      test = stub_everything
      CrawlConfig.stubs(:new).returns(test)
      @config.crawl {|t| t.should be_eql(test)}
    end
    
    it "asks the crawl configurator to crawl" do
      cc = stub_everything
      CrawlConfig.stubs(:new).returns(cc)
      cc.expects(:crawl).with()
      @config.crawl
    end
  end
end
