namespace :tarantula do

  desc 'Run tarantula tests and (Mac only) open results in your browser.'
  task :test do 
    task = Rake::TestTask.new(:tarantula_test) do |t|
      t.libs << 'test'
      t.pattern = 'test/tarantula/**/*_test.rb'
      t.verbose = true
    end
    
    begin
      Rake::Task[:tarantula_test].invoke
    rescue RuntimeError => e
      puts e.message
    end
    if PLATFORM['darwin']
      Dir.glob("tmp/tarantula/**/index.html") do |file|
        system("open #{file}") 
      end
    end
  end
  
end