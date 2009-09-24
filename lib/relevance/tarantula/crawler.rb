require 'active_record'
require 'active_record/base'
require File.expand_path(File.join(File.dirname(__FILE__), "rails_integration_proxy"))
require File.expand_path(File.join(File.dirname(__FILE__), "html_document_handler.rb"))

class Relevance::Tarantula::Crawler
  extend Forwardable
  include Relevance::Tarantula

  class CrawlTimeout < RuntimeError; end

  attr_accessor :proxy, :handlers, :skip_uri_patterns, :log_grabber,
                :reporters, :crawl_queue, :links_queued,
                :form_signatures_queued, :max_url_length, :response_code_handler,
                :times_to_crawl, :fuzzers, :test_name, :crawl_timeout
  attr_reader   :transform_url_patterns, :referrers, :failures, :successes, :crawl_start_times, :crawl_end_times

  def initialize
    @max_url_length = 1024
    @successes = []
    @failures = []
    @handlers = [@response_code_handler = Result]
    @links_queued = Set.new
    @form_signatures_queued = Set.new
    @crawl_queue = []
    @crawl_start_times, @crawl_end_times = [], []
    @crawl_timeout = 20.minutes
    @referrers = {}
    @skip_uri_patterns = [
      /^javascript/,
      /^mailto/,
      /^http/,
    ]
    self.transform_url_patterns = [
      [/#.*$/, '']
    ]
    @reporters = [Relevance::Tarantula::IOReporter.new($stderr)]
    @decoder = HTMLEntities.new
    @times_to_crawl = 1
    @fuzzers = [Relevance::Tarantula::FormSubmission]
    
    @stdout_tty = $stdout.tty?
  end

  def method_missing(meth, *args)
    super unless Result::ALLOW_NNN_FOR =~ meth.to_s
    @response_code_handler.send(meth, *args)
  end

  def transform_url_patterns=(patterns)
    @transform_url_patterns = patterns.map do |pattern|
      Array === pattern ? Relevance::Tarantula::Transform.new(*pattern) : pattern
    end
  end

  def crawl(url = "/")
    orig_links_queued = @links_queued.dup
    orig_form_signatures_queued = @form_signatures_queued.dup
    orig_crawl_queue = @crawl_queue.dup
    @times_to_crawl.times do |num|
      queue_link url
      
      begin 
        do_crawl num
      rescue CrawlTimeout => e
        puts
        puts e.message
      end
      
      puts "#{(num+1).ordinalize} crawl" if @times_to_crawl > 1

      if num + 1 < @times_to_crawl
        @links_queued = orig_links_queued
        @form_signatures_queued = orig_form_signatures_queued
        @crawl_queue = orig_crawl_queue
        @referrers = {}
      end
    end
  rescue Interrupt
    $stderr.puts "CTRL-C"
  ensure
    report_results
  end

  def finished?
    @crawl_queue.empty?
  end

  def do_crawl(number)
    while (!finished?)
      @crawl_start_times << Time.now
      crawl_the_queue(number)
      @crawl_end_times << Time.now
    end
  end

  def crawl_the_queue(number = 0)
    while (request = @crawl_queue.pop)
      request.crawl
      blip(number)
    end
  end

  def save_result(result)
    reporters.each do |reporter|
      reporter.report(result)
    end
  end

  def handle_link_results(link, result)
    handlers.each do |h|
      begin
        save_result h.handle(result)
      rescue Exception => e
        log "error handling #{link} #{e.message}"
        # TODO: pass to results
      end
    end
  end

  def follow(method, url, data=nil)
    proxy.send(method, url, data)
  end
  
  def submit(method, action, data)
    proxy.send(method, action, data)
  end

  def elasped_time_for_pass(num)
    Time.now - crawl_start_times[num]
  end

  def grab_log!
    @log_grabber && @log_grabber.grab!
  end
  
  def make_result(options)
    defaults = {
      :log       => grab_log!,
      :test_name => test_name      
    }
    Result.new(defaults.merge(options)).freeze
  end

  def handle_form_results(form, response)
    handlers.each do |h|
      save_result h.handle(Result.new(:method => form.method,
                                     :url => form.action,
                                     :response => response,
                                     :log => grab_log!,
                                     :referrer => form.action,
                                     :data => form.data.inspect,
                                     :test_name => test_name).freeze)
    end
  end

  def should_skip_url?(url)
    return true if url.blank?
    if @skip_uri_patterns.any? {|pattern| pattern =~ url}
      log "Skipping #{url}"
      return true
    end
    if url.length > max_url_length
      log "Skipping long url #{url}"
      return true
    end
  end

  def should_skip_link?(link)
    should_skip_url?(link.href) || @links_queued.member?(link)
  end

  def should_skip_form_submission?(fs)
    should_skip_url?(fs.action) || @form_signatures_queued.member?(fs.signature)
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
    dest = Link.new(dest, self, referrer)
    return if should_skip_link?(dest)
    @crawl_queue << dest
    @links_queued << dest
    dest
  end

  def queue_form(form, referrer = nil)
    fuzzers.each do |fuzzer|
      fuzzer.mutate(Form.new(form, self, referrer)).each do |fs|
        # fs = fuzzer.new(Form.new(form, self, referrer))
        fs.action = transform_url(fs.action)
        return if should_skip_form_submission?(fs)
        @referrers[fs.action] = referrer if referrer
        @crawl_queue << fs
        @form_signatures_queued << fs.signature
      end
    end
  end

  def report_dir
    File.join(rails_root, "tmp", "tarantula")
  end

  def generate_reports
    errors = []
    reporters.each do |reporter|
      begin
        reporter.finish_report(test_name)
      rescue RuntimeError => e
        errors << e
      end
    end
    unless errors.empty?
      raise errors.map(&:message).join("\n")
    end
  end

  def report_results
    puts "Crawled #{total_links_count} links and forms."
    generate_reports
  end

  def total_links_count
    @links_queued.size + @form_signatures_queued.size
  end

  def links_remaining_count
    @crawl_queue.size
  end

  def links_completed_count
      total_links_count - links_remaining_count
  end

  def blip(number = 0)
    unless verbose
      print "\r #{links_completed_count} of #{total_links_count} links completed               " if @stdout_tty
      timeout_if_too_long(number)
    end
  end
  
  def timeout_if_too_long(number = 0)
    if elasped_time_for_pass(number) > crawl_timeout
      raise CrawlTimeout, "Exceeded crawl timeout of #{crawl_timeout} seconds - skipping to the next crawl..."
    end
  end
end
