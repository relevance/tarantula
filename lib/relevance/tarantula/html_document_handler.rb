class Relevance::Tarantula::HtmlDocumentHandler 
  extend Forwardable
  def_delegators("@tarantula", :queue_link, :queue_form)

  def initialize(tarantula)
    @tarantula = tarantula
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
      queue_form(form)
    end
  end
end
