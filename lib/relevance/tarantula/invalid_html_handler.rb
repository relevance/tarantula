class Relevance::Tarantula::InvalidHtmlHandler
  include Relevance::Tarantula
  def handle(method, url, response, referrer, data = nil)
    begin
      body = HTML::Document.new(response.body, true)
    rescue Exception => e
      Result.new(false, method, url, response.code, referrer, e.message)
    else
      nil
    end
  end
end
