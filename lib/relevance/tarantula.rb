require 'forwardable'

require 'facets/enumerable/injecting'
require 'facets/kernel/metaclass'

gem 'htmlentities'
require 'htmlentities'

module Relevance; end
module Relevance; module CoreExtensions; end; end
module Relevance
  module Tarantula 
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

require 'relevance/core_extensions/ellipsize'
require 'relevance/core_extensions/file'
require 'relevance/core_extensions/response'

require 'relevance/tarantula/result'
require 'relevance/tarantula/invalid_html_handler'
require 'relevance/tarantula/transform'
require 'relevance/tarantula/crawler'
require 'relevance/tarantula/form'
require 'relevance/tarantula/form_submission'
require 'relevance/tarantula/html_reporter'

require 'relevance/tarantula/tidy_handler' if ENV['TIDY_PATH']
