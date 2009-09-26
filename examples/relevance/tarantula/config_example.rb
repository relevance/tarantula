require File.expand_path(File.join(File.dirname(__FILE__), "../..", "example_helper.rb"))

describe Relevance::Tarantula::Config do
  Config = Relevance::Tarantula::Config
  
  describe "crawl" do
    it "supplies appropriate default options to the config instance if none are supplied" do
      config_instance = stub_everything
      Config.expects(:new).with().returns(config_instance)
      config_instance.expects(:crawl_options=).with(:test_name => 'tarantula crawl', :default_root_page => '/')
      Config.crawl
    end
    
    it "passes a supplied test name to the config instance" do
      config_instance = stub_everything
      Config.expects(:new).with().returns(config_instance)
      config_instance.expects(:crawl_options=).with(:test_name => 'some name', :default_root_page => '/')
      Config.crawl('some name')
    end
    
    it "yields the config instance to a passed block" do
      config_instance = stub_everything
      Config.stubs(:new).returns(config_instance)
      Config.crawl {|t| t.should be_eql(config_instance)}
    end
    
    it "asks the config instance to crawl" do
      config_instance = stub_everything
      Config.stubs(:new).returns(config_instance)
      config_instance.expects(:run)
      Config.crawl
    end
  end
end
