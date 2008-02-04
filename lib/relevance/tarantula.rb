require 'forwardable'

require 'facets/enumerable/injecting'
require 'facets/kernel/metaclass'


module Relevance; end
module Relevance; module CoreExtensions; end; end
module Relevance
  module Tarantula 
    def log(msg)
      puts msg if ENV["VERBOSE"]
    end
    def rails_root
      ::RAILS_ROOT
    end
  end
end

require 'relevance/core_extensions/file'
require 'relevance/tarantula/results_handler'
require 'relevance/tarantula/crawler'
require 'relevance/tarantula/form'
require 'relevance/tarantula/form_submission'
require 'relevance/tarantula/html_reporter'
