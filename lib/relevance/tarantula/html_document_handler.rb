class Relevance::Tarantula::HtmlDocumentHandler 
  extend Forwardable
  def_delegators("@crawler", :queue_link, :queue_form)
  
  def initialize(crawler)
    @crawler = crawler
  end              
  # HTML::Document shouts to stderr when it sees ugly HTML
  # We don't want this -- the InvalidHtmlHandler will deal with it
  def html_doc_without_stderr_noise(html)  
    body = nil
    Recording.stderr do
      body = HTML::Document.new html
    end       
    body
  end
  def handle(result)
    response = result.response
    url = result.url
    return unless response.html?
    body = html_doc_without_stderr_noise(response.body)
    body.find_all(:tag=>'a').each do |tag|
      queue_link(tag['href'], url)
    end
    body.find_all(:tag=>'link').each do |tag|
      queue_link(tag['href'], url)
    end
    body.find_all(:tag =>'form').each do |form|
      form.attributes['action'] = url unless form.attributes['action']
      queue_form(form, url)
    end
    nil
  end
end
