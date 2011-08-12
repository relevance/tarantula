require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rspec'
require 'rspec/core/rake_task'

desc "Run all RSpec specs"
RSpec::Core::RakeTask.new :spec do |t|
  t.pattern = File.dirname(__FILE__)+"/spec/**/*_spec.rb"
end

desc "Run all RSpec specs using rcov"
RSpec::Core::RakeTask.new :rcov do |t|
  t.pattern = File.dirname(__FILE__)+"/spec/**/*_spec.rb"
  t.rcov = true
  t.rcov_opts = %[--exclude "gems/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage]
end

begin
  %w{sdoc sdoc-helpers rdiscount}.each { |name| gem name }
  require 'sdoc_helpers'
rescue LoadError => ex
  puts "sdoc support not enabled:"
  puts ex.inspect
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tarantula #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
