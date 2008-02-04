class Relevance::Tarantula::HtmlDocumentHandler 
  extend Forwardable
  def_delegators("@crawler", :queue_link, :queue_form)
  
  def initialize(crawler)
    @crawler = crawler
  end
  def handle(method, url, response, data = nil)
    body = HTML::Document.new response.body
    body.find_all(:tag=>'a').each do |tag|
      queue_link(tag['href'])
    end
    body.find_all(:tag=>'link').each do |tag|
      queue_link(tag['href'])
    end
    body.find_all(:tag =>'form').each do |form|
      form.attributes['action'] = url unless form.attributes['action']
      queue_form(form)
    end
  end
end
