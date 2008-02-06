class Relevance::Tarantula::InvalidHtmlHandler
  extend Forwardable
  def_delegators("@crawler", :queue_link, :queue_form)
  
  def initialize(crawler)
    @crawler = crawler
  end

  def handle(method, url, response, referrer, data = nil)
    begin
      body = HTML::Document.new(response.body, true)
    rescue Exception => e
      @crawler.failures << Result.new(method, url, response.code, referrer, e.message)
    end
  end
end
