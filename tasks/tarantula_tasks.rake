namespace :tarantula do

  desc 'Run tarantula tests and (Mac only) open results in your browser.'
  task :test do
    rm_rf "tmp/tarantula" 
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
    Dir.glob("tmp/tarantula/**/index.html") do |file|
      if PLATFORM['darwin']
        system("open #{file}") 
      else
        puts "You can view tarantula results at #{file}"
      end
    end
  end
  
end