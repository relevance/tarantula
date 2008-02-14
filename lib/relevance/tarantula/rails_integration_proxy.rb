require 'test/unit'

class Test::Unit::TestCase
  def tarantula_crawl(integration_test, options = {})
    url = options[:url] || "/"
    t = rails_integration_test(integration_test, options)
    t.crawl url
  end
  
  def tarantula_crawler(integration_test, options = {})
    Relevance::Tarantula::RailsIntegrationProxy.rails_integration_test(integration_test_options)
  end
end

class Relevance::Tarantula::RailsIntegrationProxy
  include Relevance::Tarantula
  extend Forwardable
  attr_accessor :integration_test

  def self.rails_integration_test(integration_test, options = {})
    t = Crawler.new
    t.max_url_length = options[:max_url_length] if options[:max_url_length] 
    t.proxy = RailsIntegrationProxy.new(integration_test)
    t.handlers << HtmlDocumentHandler.new(t)
    t.handlers << InvalidHtmlHandler.new
    t.skip_uri_patterns << /logout$/
    t.transform_url_patterns += [
      [/\?\d+$/, ''],                               # strip trailing numbers for assets
      [/^http:\/\/#{integration_test.host}/, '']    # strip full path down to relative
    ]
    t.reporters << Relevance::Tarantula::HtmlReporter
    t
  end

  def initialize(integration_test)
    @integration_test = integration_test
    @integration_test.meta.attr_accessor :response
  end
  
  [:get, :post, :put, :delete].each do |verb|
    define_method(verb) do |url, *args|
      integration_test.send(verb, url, *args)
      response = integration_test.response
      patch_response(url, response)
      response
    end
  end

  def patch_response(url, response)
    if response.code == '404'
      if File.exist?(static_content_path(url))
        case ext = File.extension(url)
        when /jpe?g|gif|psd|png|eps|pdf/
          log "Skipping #{url} (for now)"
        when /html|te?xt|css|js/
          response.body = static_content_file(url)
          response.headers["type"] = "text/#{ext}"  # readable as response.content_type
          response.meta.attr_accessor :code
          response.code = "200"
        else
          log "Skipping unknown type #{url}"
        end
      end
    end
    # don't count on metaclass taking block, e.g.
    # http://relevancellc.com/2008/2/12/how-should-metaclass-work
    response.metaclass.class_eval do
      include Relevance::CoreExtensions::Response
    end
  end
  
  def static_content_file(url)
    File.read(static_content_path(url))
  end
  
  def static_content_path(url)
    File.expand_path(File.join(rails_root, "public", url))
  end
end
