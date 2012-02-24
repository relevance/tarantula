if rails_version = ENV['RAILS_VERSION']
  require 'rubygems'
  gem "rails", rails_version
end

require "rails/version"
puts "==== Testing with Rails #{Rails::VERSION::STRING} ===="

require 'relevance/tarantula'
require 'bundler'
Bundler.require
require 'ostruct'

def test_output_dir
  File.join(File.dirname(__FILE__), "..", "tmp", "test_output")
end

# TODO change puts/print to use a single method for logging, which will then make the stubbing cleaner
def stub_puts_and_print(obj)
  obj.stubs(:puts)
  obj.stubs(:print)
end

def make_link(link, crawler=Relevance::Tarantula::Crawler.new, referrer=nil)
  Relevance::Tarantula::Link.new(link, crawler, referrer)
end

def make_form(form, crawler=Relevance::Tarantula::Crawler.new, referrer=nil)
  Relevance::Tarantula::Form.new(form, crawler, referrer)
end

def not_in_editor?
  ['TM_MODE', 'EMACS', 'VIM'].all? { |k| !ENV.has_key?(k) }
end

RSpec.configure do |c|
  c.alias_example_to :fit, :focused => true
  c.alias_example_to :xit, :disabled => true
  c.mock_with :mocha
  c.color_enabled = not_in_editor?
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true
end
