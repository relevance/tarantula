module Relevance
  module CoreExtensions

    module File 
      def extension(path)
        extname(path)[1..-1]
      end
    end

  end
end

class File
  extend Relevance::CoreExtensions::File
end
