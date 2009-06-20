class Relevance::Tarantula::Link
  
  class << self
    include ActionView::Helpers::UrlHelper
    # method_javascript_function needs this method
    def protect_against_forgery?
      false
    end
  end
  
  METHOD_REGEXPS = {}
  [:put, :delete, :post].each do |m|
    # remove submit from the end so we'll match with or without forgery protection
    s = method_javascript_function(m).gsub( /f.submit();/, "" )
    # don't just match this.href in case a different url was passed originally
    s = Regexp.escape(s).gsub( /this.href/, ".*" )
    METHOD_REGEXPS[m] = /#{s}/
  end
  
  def href
    @href ||= crawler.transform_url(link)
  end
  
  # TODO store link, crawler, referrer
  # TODO handle href properly as lazy attribute
  def initialize(link, crawler, referrer)
    if String === link || link.nil?
      @href = link
      @method = :get
    else # should be a tag
      @href = link['href'] ? link['href'].downcase : nil
      @tag = link
    end
  end
  
  def crawl
    # TODO obey demeter
    response = crawler.proxy.send(method, href)
    log "Response #{response.code} for #{link}"
    handle_link_results(link, make_result(response))
  end
  
  def make_result(response)
    Result.new(:method    => method,
               :url       => href,
               :response  => response,
               # TODO can we handle this better?
               :log       => crawler.grab_log!,
               :referrer  => referrer,
               # TODO can we handle this better?
               :test_name => crawler.test_name).freeze  
  end
  
  def method
    @method ||= begin
      (@tag &&
       [:put, :delete, :post].detect do |m| # post should be last since it's least specific
         @tag['onclick'] =~ METHOD_REGEXPS[m]
       end) ||
      :get
    end
  end
  
  def ==(obj)
    obj.respond_to?(:href) && obj.respond_to?(:method) &&
      self.href.to_s == obj.href.to_s && self.method.to_s == obj.method.to_s
  end
  alias :eql? :==
  
  def hash
    to_s.hash
  end
  
  def to_s
    "<Relevance::Tarantula::Link href=#{href}, method=#{method}>"
  end
  
end
