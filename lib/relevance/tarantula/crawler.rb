require 'relevance/tarantula/rails_integration_proxy'
require 'relevance/tarantula/html_document_handler'

class Relevance::Tarantula::Crawler
  extend Forwardable
  include Relevance::Tarantula
  
  attr_accessor :proxy, :handlers, :skip_uri_patterns,
                :reporters, :links_to_crawl, :links_queued, :forms_to_crawl,
                :form_signatures_queued, :max_url_length
  attr_reader   :transform_url_patterns, :referrers, :failures, :successes
   
  def initialize
    @max_url_length = 1024
    @successes = []
    @failures = []
    @handlers = [Result]
    @links_queued = Set.new
    @form_signatures_queued = Set.new
    @links_to_crawl = []
    @forms_to_crawl = []
    @referrers = {}
    @skip_uri_patterns =[
      /^mailto/,
      /^http/,                                      
    ]
    self.transform_url_patterns = [
      [/#.*$/, '']
    ]
    @reporters = []
    @decoder = HTMLEntities.new
    
  end
  
  def transform_url_patterns=(patterns)
    @transform_url_patterns = patterns.map do |pattern| 
      Array === pattern ? Relevance::Tarantula::Transform.new(*pattern) : pattern
    end
  end
  
  def crawl(url = "/")
    queue_link url
    do_crawl
  rescue Interrupt
    $stderr.puts "CTRL-C"
  ensure
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
      handle_link_results(link, response)
      blip
    end
  end  
  
  def save_result(result)
    return if result.nil?
    collection = result.success ? successes : failures
    collection << result
  end
  
  def handle_link_results(link, response)
    handlers.each do |h| 
      begin
        save_result h.handle(Result.new(:method => "get", 
                                       :url => link, 
                                       :response => response, 
                                       :referrer => referrers[link]).freeze)
      rescue Exception => e
        log "error handling #{link} #{e.message}"
        # TODO: pass to results
      end
    end
  end
  
  def crawl_queued_forms
    while (form = @forms_to_crawl.pop)
      begin
        response = proxy.send(form.method, form.action, form.data)
      rescue ActiveRecord::RecordNotFound
        log "Skipping #{form.action}, presumed ok that record is missing"
      end
      log "Response #{response.code} for #{form}"
      handle_form_results(form, response)
      blip
    end
  end  

  def handle_form_results(form, response)
    handlers.each do |h| 
      save_result h.handle(Result.new(:method => form.method, 
                                     :url => form.action, 
                                     :response => response, 
                                     :data => form.data.inspect).freeze)
    end
  end
  
  def should_skip_link?(url)
    return true if url.blank?
    if @skip_uri_patterns.any? {|pattern| pattern =~ url}
      log "Skipping #{url}"
      return true
    end
    if url.length > max_url_length
      log "Skipping long url #{url}"
      return true
    end
    @links_queued.member?(url)
  end
  
  def should_skip_form_submission?(fs)
    @form_signatures_queued.member?(fs.signature)
  end
  
  def transform_url(url)
    return unless url
    url = @decoder.decode(url)    
    @transform_url_patterns.each do |pattern|
      url = pattern[url]
    end
    url
  end
  
  def queue_link(dest, referrer = nil)
    dest = transform_url(dest)
    return if should_skip_link?(dest)
    @referrers[dest] = referrer if referrer
    @links_to_crawl << dest 
    @links_queued << dest
    dest
  end
  
  def queue_form(form, referrer = nil)
    fs = FormSubmission.new(Form.new(form))
    fs.action = transform_url(fs.action)
    return if should_skip_form_submission?(fs)
    @referrers[fs.action] = referrer if referrer
    @forms_to_crawl << fs
    @form_signatures_queued << fs.signature
  end
  
  def report_dir
    File.join(rails_root, "tmp", "tarantula")
  end

  def generate_reports
    FileUtils.mkdir_p(report_dir)
    reporters.each do |reporter|
      reporter.report(report_dir, self)
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
    puts "Writing results to #{report_dir}"
    generate_reports
    report_to_console
  end
  
  def total_links_count
    @links_queued.size + @form_signatures_queued.size
  end

  def links_remaining_count
    @links_to_crawl.size + @forms_to_crawl.size
  end

  def links_completed_count
      total_links_count - links_remaining_count
  end

  def blip
    unless verbose
      print "\r #{links_completed_count} of #{total_links_count} links completed               "
    end
  end  
end