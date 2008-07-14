require "#{File.dirname(__FILE__)}/../test_helper"
require "relevance/tarantula"

class TarantulaTest < ActionController::IntegrationTest
  fixtures :all

  def test_tarantula
    post '/session', :login => 'quentin', :password => 'monkey'
    follow_redirect!
    tarantula_crawl(self)
  end
end
