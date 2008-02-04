require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the tarantula plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the tarantula plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Tarantula'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'rcov'
  require "rcov/rcovtask"

  namespace :coverage do
    rcov_output = ENV["CC_BUILD_ARTIFACTS"] || 'tmp/coverage'
    rcov_exclusions = %w{
    }.join(',')
  
    desc "Delete aggregate coverage data."
    task(:clean) { rm_f "rcov_tmp" }
  
    Rcov::RcovTask.new(:unit => :clean) do |t|
      t.test_files = FileList['test/**/*_test.rb']
      t.rcov_opts = ["--sort coverage", "--aggregate 'rcov_tmp'", "--html", "--rails", "--exclude '#{rcov_exclusions}'"]
      t.output_dir = rcov_output + '/unit'
    end
  
    desc "Generate and open coverage report"
    task(:all => [:unit]) do
      system("open #{rcov_output}/unit/index.html") if PLATFORM['darwin']
    end
  end
rescue LoadError
  if RUBY_PLATFORM =~ /java/
    puts 'running in jruby - rcov tasks not available'
  else
    puts 'sudo gem install rcov # if you want the rcov tasks'
  end
end
