class Relevance::Tarantula::Form
  extend Forwardable
  def_delegators("@tag", :search)
  
  attr_accessor :crawler, :referrer
  
  def initialize(tag, crawler, referrer)
    @tag, @crawler, @referrer = tag, crawler, referrer
  end
  
  def action
    @tag['action'].downcase
  end
  
  def method
    (rails_method_hack or @tag['method'] or 'get').downcase
  end
  
  def rails_method_hack
    (tag = @tag.at('input[@name="_method"]')) && tag["value"]
  end

end
