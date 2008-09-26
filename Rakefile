require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'

begin
  gem 'technicalpickles-echoe'
rescue LoadError => e
  puts "Couldn't find the correct version of echoe - please install from forked version on github: http://github.com/technicalpickles/echoe/ ->"
  puts "sudo gem install technicalpickles-echoe --source http://gems.github.com"
end

require 'echoe'
require 'lib/relevance/tarantula.rb'

echoe = Echoe.new('tarantula') do |p|
  p.rubyforge_name = 'thinkrelevance'
  p.author = ["Relevance"]
  p.email = 'opensource@thinkrelevance.com'
  p.version = Relevance::Tarantula::VERSION
  p.summary = "A big hairy fuzzy spider that crawls your site, wreaking havoc"
  p.description = "A big hairy fuzzy spider that crawls your site, wreaking havoc"
  p.url = "http://opensource.thinkrelevance.com/wiki/tarantula"
  p.rdoc_pattern = /^(lib|bin)|txt|rdoc|CHANGELOG|MIT-LICENSE$/
  rdoc_template = `allison --path`.strip << ".rb"
  p.rdoc_template = rdoc_template
  p.test_pattern = 'test/**/*_test.rb'
  p.manifest_name = 'manifest.txt'
  p.dependencies = ['htmlentities', 'hpricot', 'facets >=2.4.3']
  p.development_dependencies = ['ruby-debug', 'test-spec']
end

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
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'rcov'
  require "rcov/rcovtask"

  namespace :coverage do
    rcov_output = ENV["CC_BUILD_ARTIFACTS"] || 'tmp/coverage'
    rcov_exclusions = %w{ /Library/Ruby/* }.join(',')

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
