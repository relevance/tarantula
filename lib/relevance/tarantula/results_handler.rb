Relevance::Tarantula::Result = Struct.new(:success, :method, :url, :code, :referrer, :data) do
  def short_description
    [method,url].join(" ")
  end
  def sequence_number
    @sequence_number ||= (self.class.next_number += 1)
  end
  def file_name
    "#{sequence_number}.html"
  end
  class <<self
    attr_accessor :next_number
  end
  self.next_number = 0
end

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