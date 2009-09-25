module Relevance::Tarantula
  module Runner
    def self.run
      ARGV.each do |filename|
        ::Relevance::Tarantula::FileLoader.load_file(filename)
      end
    rescue => ex
      $stderr.puts "#{ex.message} (#{ex.class.name})"
      $stderr.puts ex.backtrace * "\n"
    end
  end
end