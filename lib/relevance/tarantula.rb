require 'forwardable'

TARANTULA_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../.."))

# bringing in xss-shield requires a bunch of other dependencies
# still not certain about this, if it ruins your world please let me know           
require 'erb'    
gem 'activesupport'                                                        
gem 'actionpack'
require 'active_support'
require 'action_controller'
#xss_shield_path = File.join(TARANTULA_ROOT, %w{vendor xss-shield})
#$: << File.join(xss_shield_path, "lib")
#require File.join(xss_shield_path, "init")

gem 'facets'
gem 'htmlentities'

require 'facets/kernel/meta'
require 'facets/metaid'
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
     

require 'relevance/core_extensions/test_case'
require 'relevance/core_extensions/ellipsize'
require 'relevance/core_extensions/file'
require 'relevance/core_extensions/response'

require 'relevance/tarantula/html_reporter'
require 'relevance/tarantula/html_report_helper'
require 'relevance/tarantula/io_reporter'
require 'relevance/tarantula/recording'
require 'relevance/tarantula/response'
require 'relevance/tarantula/result'
require 'relevance/tarantula/log_grabber'
require 'relevance/tarantula/invalid_html_handler'
require 'relevance/tarantula/transform'
require 'relevance/tarantula/crawler'
require 'relevance/tarantula/form'
require 'relevance/tarantula/form_submission'
require 'relevance/tarantula/attack'
require 'relevance/tarantula/attack_form_submission'
require 'relevance/tarantula/attack_handler'
require 'relevance/tarantula/link'

require 'relevance/tarantula/tidy_handler' if ENV['TIDY_PATH']
