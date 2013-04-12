require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require "bundler/gem_tasks"
Dir["lib/relevance/tasks/*.rake"].each {|f| load f }

begin
  require 'rspec'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new('spec') do |t|
    t.verbose = true
  end

  desc "Run all RSpec specs using rcov"
  RSpec::Core::RakeTask.new :rcov do |t|
    t.pattern = File.dirname(__FILE__)+"/spec/**/*_spec.rb"
    t.rcov = true
    t.rcov_opts = %[--exclude "gems/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage]
  end

  task :default => :spec
rescue LoadError
  puts "rspec, or one of its dependencies, is not available. Install it with: sudo gem install rspec"
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tarantula #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
