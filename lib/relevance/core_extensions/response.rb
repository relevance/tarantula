# dynamically mixed in to response objects
module Relevance
  module CoreExtensions
    module Response 
      def html?
        # some versions of Rails integration tests don't set content type
        # so we are treating nil as html. A better fix would be welcome here.
        return content_type.nil? || content_type.html?
      end
    end
  end
end
