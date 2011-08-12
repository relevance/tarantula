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

  s.add_development_dependency "micronaut"
  s.add_development_dependency "hpricot"
  s.add_development_dependency "sdoc"
  s.add_development_dependency "sdoc-helpers"
  s.add_development_dependency "rdiscount"
  s.add_development_dependency "log_buddy"
  s.add_development_dependency "mocha"
  s.add_development_dependency "rails"
  s.add_development_dependency "htmlentities"
end
