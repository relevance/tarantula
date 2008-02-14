class Relevance::Tarantula::Result
  HASHABLE_ATTRS = [:success, :method, :url, :response, :referrer, :data, :description]
  attr_accessor *HASHABLE_ATTRS
  include Relevance::Tarantula

  def initialize(hash)
    hash.each do |k,v|
      raise ArgumentError, k unless HASHABLE_ATTRS.member?(k)
      self.instance_variable_set("@#{k}", v)
    end
  end
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
    def handle(result)
      retval = result.dup
      retval.success = successful?(result.response) 
      retval.description = "Bad HTTP Response" unless retval.success
      retval
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