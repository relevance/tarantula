require 'test_help'

class Relevance::Tarantula::Config < ActionController::IntegrationTest
  attr_accessor :crawl_options
  
  def initialize(name)
    super
  end
  
  def test_tarantula
    crawler = tarantula_crawler(self, :test_name => @options[:test_name])
    crawler.handlers += @handlers
    crawler.crawl(@root_page)
    @tarantula_config.teardown_fixtures
  end

  class CrawlConfig
    def initialize(options)
      @tarantula_config = ::Relevance::Tarantula::Config.new('test_tarantula')
      @options = options
    end
    
    def root_page(url)
      raise "Multiple root pages are not allowed for a single crawl" if @root_page
      @root_page = url
    end
    
    # TODO Need a better name for this.  "add_handler" sounds too procedural,
    #      and it's not clear what a "handler" is.  "#response_check" maybe?
    def add_handler(handler)
      @handlers ||= []
      case handler
      when Symbol, String
        @handlers << HANDLERS[handler.to_s]
      else
        @handlers << handler
      end
    end
    
    def crawl
      
      # @tarantula_config.setup_fixtures
      # crawler = @tarantula_config.tarantula_crawler(@tarantula_config, :test_name => @options[:test_name])
      # crawler.handlers += @handlers
      # crawler.crawl(@root_page)
      # @tarantula_config.teardown_fixtures
    end
  end
  
  def self.crawl(label="tarantula crawl")
    cc = CrawlConfig.new(:test_name => label, :default_root_page => '/')
    yield cc if block_given?
    cc.crawl
  end
end
