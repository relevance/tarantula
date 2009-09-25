TARANTULA_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../.."))

require 'forwardable'
require 'erb'
require 'active_support'
require 'action_controller'

# bringing in xss-shield requires a bunch of other dependencies
# still not certain about this, if it ruins your world please let me know
#xss_shield_path = File.join(TARANTULA_ROOT, %w{vendor xss-shield})
#$: << File.join(xss_shield_path, "lib")
#require File.join(xss_shield_path, "init")

require 'htmlentities'

module Relevance; end
module Relevance; module CoreExtensions; end; end
module Relevance
  module Tarantula
    def tarantula_home
      File.expand_path(File.join(File.dirname(__FILE__), "../.."))
    end
    def log(msg)
      puts msg if verbose
    end
    def rails_root
      ::RAILS_ROOT
    end
    def verbose
      ENV["VERBOSE"]
    end
  end
end

%w{
  test_case
  ellipsize
  file
  response
  metaclass
  string_chars_fix
}.each do |fn|
  require File.join(TARANTULA_ROOT, 'lib/relevance/core_extensions', fn)
end

%w{
  html_reporter
  html_report_helper
  io_reporter
  recording
  response
  result
  log_grabber
  invalid_html_handler
  transform
  crawler
  basic_attack
  form
  form_submission
  attack
  attack_handler
  link
}.each do |fn|
  require File.join(TARANTULA_ROOT, 'lib/relevance/tarantula', fn)
end

require File.join(TARANTULA_ROOT, 'lib/relevance/tarantula', 'tidy_handler') if ENV['TIDY_PATH']
