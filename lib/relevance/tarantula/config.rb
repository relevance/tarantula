module Relevance::Tarantula::Config
  class CrawlConfig
    def initialize(options)
      @options = options
    end
    
    def crawl
      # TODO create and initialize crawler
      # TODO crawl
    end
  end
  
  def crawl(label="tarantula crawl")
    cc = CrawlConfig.new(:test_name => label, :default_root_page => '/')
    yield cc if block_given?
    cc.crawl
  end
end