require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'micronaut'
require 'micronaut/rake_task'

begin
  require 'jeweler'
  files = ["CHANGELOG", "LICENSE", "Rakefile", "README.rdoc", "VERSION.yml"]
  files << Dir["examples/**/*", "laf/**/*", "lib/**/*", "tasks/**/*", "template/**/*"]
  
  Jeweler::Tasks.new do |s|
    s.name = "tarantula-rails3"
    s.summary = "A big hairy fuzzy spider that crawls your site, wreaking havoc"
    s.description = "A big hairy fuzzy spider that crawls your site, wreaking havoc"
    s.homepage = "http://github.com/nashby/tarantula-rails3"
    s.email = "opensource@thinkrelevance.com"
    s.authors = ["Relevance, Inc."]
    s.require_paths = ["lib"]
    s.files = files.flatten
    s.add_dependency 'htmlentities', '>= 4.2.0'
    s.add_dependency 'hpricot', '>= 0.8.1'
    s.add_development_dependency 'micronaut'
    s.add_development_dependency 'log_buddy'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

desc "Run all micronaut examples"
Micronaut::RakeTask.new :examples do |t|
  t.pattern = File.dirname(__FILE__)+"/examples/**/*_example.rb"
end

desc "Run all micronaut examples using rcov"
Micronaut::RakeTask.new :rcov do |t|
  t.pattern = File.dirname(__FILE__)+"/examples/**/*_example.rb"
  t.rcov = true
  t.rcov_opts = %[--exclude "gems/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage]
end

if ENV["RUN_CODE_RUN"]
  task :default => [:check_dependencies, "examples:multi_rails"]
else
  task :default => [:check_dependencies, :examples]
end

begin
  %w{sdoc sdoc-helpers rdiscount}.each { |name| gem name }
  require 'sdoc_helpers'
rescue LoadError => ex
  puts "sdoc support not enabled:"
  puts ex.inspect
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tarantula #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
