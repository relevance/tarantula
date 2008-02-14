require 'rubygems'
begin
  gem 'tidy'
  require 'tidy'
rescue Gem::LoadError
  # tidy not available
end

if defined? Tidy
  Tidy.path = ENV['TIDY_PATH'] if ENV['TIDY_PATH']

  class Relevance::Tarantula::TidyHandler 
    include Relevance::Tarantula
    def initialize(options = {})
      @options = {:show_warnings=>true}.merge(options)
    end
    def handle(method, url, response, referrer, data = nil)
      return unless response.html?
      tidy = Tidy.open(@options) do |tidy|
        xml = tidy.clean(response.body)
        tidy
      end
      Result.new(false, method, url, response, referrer, tidy.errors.inspect) unless tidy.errors.blank?
    end
  end
end
