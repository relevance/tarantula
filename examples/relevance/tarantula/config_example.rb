require File.expand_path(File.join(File.dirname(__FILE__), "../..", "example_helper.rb"))

describe Relevance::Tarantula::Config::CrawlConfig do
  Config = Relevance::Tarantula::Config
  CrawlConfig = Relevance::Tarantula::Config::CrawlConfig
  TarantulaIntegrationTest = Relevance::Tarantula::Config::TarantulaIntegrationTest
  
  describe "crawl" do
    it "supplies appropriate default options to the config instance if none are supplied" do
      test_instance = stub_everything
      TarantulaIntegrationTest.expects(:new).with().returns(test_instance)
      test_instance.expects(:crawl_options=).with(:test_name => 'tarantula crawl', :default_root_page => '/')
      Config.crawl
    end
    
    it "passes a supplied test name to the config instance" do
      test_instance = stub_everything
      TarantulaIntegrationTest.expects(:new).with().returns(test_instance)
      test_instance.expects(:crawl_options=).with(:test_name => 'some name', :default_root_page => '/')
      Config.crawl('some name')
    end
    
    it "yields the config instance to a passed block" do
      config_instance = stub_everything
      CrawlConfig.stubs(:new).returns(config_instance)
      Config.crawl {|t| t.should be_eql(config_instance)}
    end
    
    it "asks the config instance to crawl" do
      config_instance = stub_everything
      CrawlConfig.stubs(:new).returns(config_instance)
      config_instance.expects(:_crawl)
      Config.crawl
    end
  end
end
