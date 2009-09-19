module Relevance::Tarantula
  class FileLoader
    
    def self.load_file(filename)
      scope = Object.new
      class <<scope
        include Relevance::Tarantula::Config
        def get_binding; binding; end
      end
      eval(IO.read(filename), scope.get_binding)
    end
    
  end
end