Relevance::Tarantula::Result = Struct.new(:method, :url, :code, :data)
class Relevance::Tarantula::ResultsHandler
  include Relevance::Tarantula
  attr_accessor :successes, :failures
  
  def initialize
    @successes = []
    @failures = []
  end
  
  def success_codes 
    %w{200 201 302 401}
  end
  
  def successful?(response)
    success_codes.member?(response.code)
  end
  
  def handle(method, url, response, data = nil)
    collection = successful?(response) ? @successes : @failures
    collection << Result.new(method, url, response.code, data)
  end
end