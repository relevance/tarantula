basedir = File.dirname(__FILE__)
$:.unshift "#{basedir}/../lib"
require 'rubygems'
require 'test/spec'
require 'mocha'
require 'ruby-debug'
require 'relevance/tarantula'

# needed for html-scanner, grr
gem 'activesupport'
require 'active_support'
gem 'actionpack'
require 'action_controller'

class Test::Unit::TestCase 
  def test_output_dir
    File.join(File.dirname(__FILE__), "..", "tmp", "test_output")
  end
end