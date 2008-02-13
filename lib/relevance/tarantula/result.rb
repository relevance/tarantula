Relevance::Tarantula::Result = Struct.new(:success, :method, :url, :response, :referrer, :data) do
  include Relevance::Tarantula

  def short_description
    [method,url].join(" ")
  end
  def sequence_number
    @sequence_number ||= (self.class.next_number += 1)
  end
  def file_name
    "#{sequence_number}.html"
  end
  def code
    response && response.code
  end
  def body
    response && response.body
  end
  class <<self
    attr_accessor :next_number
    def handle(method, url, response, referrer, data = nil)
      Result.new(successful?(response), method, url, response, referrer, data)
    end
    def success_codes 
      %w{200 201 302 401}
    end

    def successful?(response)
      success_codes.member?(response.code)
    end
  end
  self.next_number = 0
  
  
end