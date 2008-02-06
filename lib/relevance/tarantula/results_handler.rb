Relevance::Tarantula::Result = Struct.new(:success, :method, :url, :code, :referrer, :data)
class Relevance::Tarantula::ResultsHandler
  include Relevance::Tarantula
  
  def success_codes 
    %w{200 201 302 401}
  end
  
  def successful?(response)
    success_codes.member?(response.code)
  end
  
  def handle(method, url, response, referrer, data = nil)
    Result.new(successful?(response), method, url, response.code, referrer, data)
  end
end