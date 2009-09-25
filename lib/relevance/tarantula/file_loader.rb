module Relevance::Tarantula
  class FileLoader
    
    def self.load_file(filename)
      scope = ::Relevance::Tarantula::Config
      scope.class_eval(IO.read(filename), File.expand_path(filename), 1)
    end
    
  end
end