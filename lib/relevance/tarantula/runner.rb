module Relevance::Tarantula
  module Runner
    def self.run
      FileUtils.rm_rf Dir["#{RAILS_ROOT}/tmp/tarantula/*"]
      ARGV.each do |filename|
        ::Relevance::Tarantula::FileLoader.load_file(filename)
      end
      result = ::Relevance::Tarantula::Config::TarantulaIntegrationTest.result
      result.errors.each do |error|
        puts error.long_display
      end
      result.passed? ? 0 : 1
    rescue => ex
      $stderr.puts "#{ex.message} (#{ex.class.name})"
      $stderr.puts ex.backtrace * "\n"
      1
    end
  end
end