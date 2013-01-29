# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "relevance/tarantula/version"

Gem::Specification.new do |s|
  s.name        = "tarantula"
  s.version     = Relevance::Tarantula::VERSION
  s.authors     = ["Relevance, Inc."]
  s.email       = ["opensource@thinkrelevance.com"]
  s.homepage    = "https://github.com/relevance/tarantula"
  s.summary     = %q{A big hairy fuzzy spider that crawls your site, wreaking havoc}
  s.description = "Tarantula is a big fuzzy spider. It crawls your Rails 2.3 and 3.x applications, fuzzing data to see what breaks."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {examples,template}`.split("\n")

  s.add_runtime_dependency "htmlentities", "~> 4.3.0"
  s.add_runtime_dependency "hpricot", "~> 0.8.4"

  s.add_development_dependency "rspec", "~> 2.12.0"
  s.add_development_dependency 'rdoc', '~> 3.12.0'
  s.add_development_dependency "log_buddy", "~> 0.6.0"
  s.add_development_dependency "mocha", "~> 0.13.2"
  s.add_development_dependency "rails", ">= 2.3.0"
end
