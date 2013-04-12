require 'forwardable'
require 'erb'
require 'active_support'
require 'action_controller'
require 'htmlentities'

if RUBY_VERSION < '1.9.1'
  warn "***************************************************"
  warn "tarantula will stop supporting ruby 1.8.x in 0.6.0."
  warn "***************************************************"
end

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
      ::Rails.root.to_s
    end
    def verbose
      ENV["VERBOSE"]
    end
  end
end

require "relevance/core_extensions/test_case"
require "relevance/core_extensions/ellipsize"
require "relevance/core_extensions/file"
require "relevance/core_extensions/response"
require "relevance/core_extensions/metaclass"

require "relevance/tarantula/html_reporter"
require "relevance/tarantula/html_report_helper"
require "relevance/tarantula/io_reporter"
require "relevance/tarantula/recording"
require "relevance/tarantula/response"
require "relevance/tarantula/result"
require "relevance/tarantula/log_grabber"
require "relevance/tarantula/invalid_html_handler"
require "relevance/tarantula/transform"
require "relevance/tarantula/crawler"
require "relevance/tarantula/basic_attack"
require "relevance/tarantula/form"
require "relevance/tarantula/form_submission"
require "relevance/tarantula/attack"
require "relevance/tarantula/attack_handler"
require "relevance/tarantula/link"

require "relevance/tarantula/tidy_handler" if ENV['TIDY_PATH']
