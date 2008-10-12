if ENV["RAILS_ENV"] == "test"
  path = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib relevance tarantula]))
  require path
end