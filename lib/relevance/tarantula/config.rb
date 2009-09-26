require 'test_help'
require 'test/unit/testresult' unless RUBY_VERSION =~ /^1\.9\./

class Test::Unit::TestResult
  attr_reader :errors
end

class Relevance::Tarantula::Config < ActionController::IntegrationTest
  attr_accessor :crawl_options, :crawl_block
  
  def initialize(name='test_tarantula')
    super(name)
  end
  
  def name
    if @crawl_options && @crawl_options[:test_name]
      "Tarantula crawl (#{@crawl_options[:test_name]})"
    else
      super
    end
  end
  
  def test_tarantula
    crawl_block.call(self) if crawl_block
    crawler = tarantula_crawler(self, :test_name => @crawl_options[:test_name])
    crawler.handlers += @handlers if @handlers
    crawler.crawl(@root_page)
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
  
  def self.result
    @result ||= Test::Unit::TestResult.new
  end
  
  def self.crawl(label="tarantula crawl", &block)
    tc = new
    tc.crawl_options = {:test_name => label, :default_root_page => '/'}
    tc.crawl_block = block if block_given?
    tc.run(result) {|a, b| }
  end
end
