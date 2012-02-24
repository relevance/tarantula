# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "relevance/tarantula/version"

Gem::Specification.new do |s|
  s.name        = "tarantula"
  s.version     = Relevance::Tarantula::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Relevance, Inc."]
  s.email       = ["opensource@thinkrelevance.com"]
  s.homepage    = "https://github.com/relevance/tarantula"
  s.summary     = %q{A big hairy fuzzy spider that crawls your site, wreaking havoc}
  s.description = %q{A big hairy fuzzy spider that crawls your site, wreaking havoc}

  s.rubyforge_project = "tarantula"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {examples,template}`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency "htmlentities", "~> 4.3.0"
  s.add_runtime_dependency "hpricot", "~> 0.8.4"

  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency 'rdoc', '~> 3.12.0'
  s.add_development_dependency "log_buddy", "~> 0.6.0"
  s.add_development_dependency "mocha", "~> 0.9.12"
  s.add_development_dependency "rails", ">= 2.3.0"
end
