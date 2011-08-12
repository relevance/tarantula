module Relevance
  module Tarantula

    class Transform 
      attr_accessor :from, :to
      def initialize(from, to)
        @from = from
        @to = to
      end
      def [](string)
        case to
        when Proc
          string.gsub(from, &to)
        else
          string.gsub(from, to)
        end
      end
    end

  end
end
