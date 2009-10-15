require 'test_help'
require 'test/unit/testresult' unless RUBY_VERSION =~ /^1\.9\./

class Test::Unit::TestResult
  attr_reader :errors
end

class Relevance::Tarantula::Config #< ActionController::IntegrationTest
  
  class CrawlConfig
    HANDLERS = {
      :attack => Relevance::Tarantula::AttackHandler.new
    }
    
    if defined? Tidy
      HANDLERS[:tidy] = Relevance::Tarantula::TidyHandler.new
    end
    
    attr_accessor :test_case

    def initialize(label)
      @label = label
      @test_case = TarantulaIntegrationTest.new
      @crawler = @test_case.crawler = Relevance::Tarantula::RailsIntegrationProxy.rails_integration_test(@test_case, :test_name => @label)
    end

    def _crawl
      @test_case.crawl_options = {:test_name => @label, :default_root_page => '/'}
      @test_case.run(TarantulaIntegrationTest.result) {|a, b| }
    end

    def root_page(url)
      raise "Multiple root pages are not allowed for a single crawl" if @test_case.root_page
      @test_case.root_page = url
    end
    
    def crawl_timeout(time)
      @crawler.crawl_timeout = time
    end
    
    def times_to_crawl(number)
      @crawler.times_to_crawl = number
    end
    
    def method_missing(meth, *args)
      super unless Relevance::Tarantula::Result::ALLOW_NNN_FOR =~ meth.to_s
      @crawler.response_code_handler.send(meth, *args)
    end
    
    def attack(name, options)
      add_handler(:attack)
      
      attack_hash = {:name => name, :input => options[:input]}
      
      if options.include?(:output)
        attack_hash[:output] = if options[:output] == :input
                                 options[:input]
                               else
                                 options[:output]
                               end
      end
      
      Relevance::Tarantula::FormSubmission.attacks << attack_hash
    end

    # TODO Need a better name for this.  "add_handler" sounds too procedural,
    #      and it's not clear what a "handler" is.  "#response_check" maybe?
    def add_handler(handler)
      case handler
      when Symbol, String
        handler_instance = HANDLERS[handler.to_sym]
      else
        handler_instance = handler
      end

      unless @crawler.handlers.include?(handler_instance)
        @crawler.handlers << handler_instance
      end
    end
  end
  
  class TarantulaIntegrationTest < ActionController::IntegrationTest
    attr_accessor :crawl_options, :crawler, :root_page
    
    def self.result
      @result ||= Test::Unit::TestResult.new
    end

    def initialize
      super('test_tarantula')
    end
  
    def name
      if @crawl_options && @crawl_options[:test_name]
        "Tarantula crawl (#{@crawl_options[:test_name]})"
      else
        super
      end
    end
  
    def test_tarantula
      crawler.crawl(@root_page || @crawl_options[:default_root_page])
    end
  end
  
  def self.crawl(label="tarantula crawl")
    cc = CrawlConfig.new(label)
    yield cc if block_given?
    cc._crawl
  end
  
  def self.setup
    yield TarantulaIntegrationTest
  end

end
