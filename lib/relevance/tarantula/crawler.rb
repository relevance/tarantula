require 'relevance/tarantula/rails_integration_proxy'
require 'relevance/tarantula/html_document_handler'

Relevance::Tarantula::Transform = Struct.new(:from, :to)

class Relevance::Tarantula::Crawler
  extend Forwardable
  include Relevance::Tarantula
  def_delegators("@results_handler", :failures, :successes)

  def self.rails_integration_test(integration_test, url = "/")
    t = self.new
    t.proxy = RailsIntegrationProxy.new(integration_test)
    t.handlers << HtmlDocumentHandler.new(t)
    t.skip_uri_patterns << /logout$/
    t.transform_url_patterns = [
      [/\?\d+$/, ''],                               # strip trailing numbers for assets
      [/^http:\/\/#{integration_test.host}/, '']    # strip full path down to relative
    ].map {|x| Transform.new(*x)}
    t.reporters << Relevance::Tarantula::HtmlReporter
    t.crawl url
    t
  end
  
  def initialize
    @results_handler = ResultsHandler.new
    @handlers = [@results_handler]
    @links_queued = Set.new
    @form_signatures_queued = Set.new
    @links_to_crawl = []
    @forms_to_crawl = []
    @skip_uri_patterns =[
      /^mailto/,
      /^http/,                                      
    ]
    @transform_url_patterns = []
    @reporters = []
  end
  
  attr_accessor :proxy, :handlers, :skip_uri_patterns, :transform_url_patterns,
                :reporters, :links_to_crawl, :links_queued, :forms_to_crawl,
                :form_signatures_queued
  
  def crawl(url = "/")
    queue_link url
    do_crawl
    report_results
  end

  def finished?
    @links_to_crawl.empty? && @forms_to_crawl.empty?
  end
  
  def do_crawl
    while (!finished?)
      crawl_queued_links
      crawl_queued_forms
    end
  end
  
  def crawl_queued_links
    while (link = @links_to_crawl.pop)
      response = proxy.get link
      log "Response #{response.code} for #{link}"
      handlers.each {|h| h.handle("get", link, response)}
    end
  end  
  
  def crawl_queued_forms
    while (form = @forms_to_crawl.pop)
      response = proxy.send(form.method, form.action, form.data)
      log "Response #{response.code} for #{form}"
      handle_form_results(form, response)
    end
  end  

  def handle_form_results(form, response)
    handlers.each {|h| h.handle(form.method, form.action, response, form.data)}
  end
  
  def should_skip_link?(url)
    if @skip_uri_patterns.any? {|pattern| pattern =~ url}
      log "Skipping #{url}"
      return true
    end
    @links_queued.member?(url)
  end
  
  def should_skip_form_submission?(fs)
    @form_signatures_queued.member?(fs.signature)
  end
  
  def transform_url(url)
    @transform_url_patterns.each do |pattern|
      url = url.gsub(pattern.from, pattern.to)
    end
    url
  end
  
  def queue_link(dest)
    return unless dest
    dest = transform_url(dest)
    return if should_skip_link?(dest)
    @links_to_crawl << dest 
    @links_queued << dest
    dest
  end
  
  def queue_form(form)
    fs = FormSubmission.new(Form.new(form))
    fs.action = transform_url(fs.action)
    return if should_skip_form_submission?(fs)
    @forms_to_crawl << fs
    @form_signatures_queued << fs.signature
  end
  
  def report_dir
    File.join(rails_root, "tmp", "tarantula")
  end

  def generate_reports
    FileUtils.mkdir_p(report_dir)
    reporters.each do |reporter|
      reporter.report(report_dir, @results_handler)
    end
  end
  
  def report_to_console
    unless (failures).empty?
      $stderr.puts "****** FAILURES"
      failures.each do |failure|
        $stderr.puts "#{failure.code}: #{failure.url}"
      end
      raise "#{failures.size} failures"
    end
  end
  
  def report_results
    generate_reports
    report_to_console
  end
end