# dynamically mixed in to response objects
module Relevance
  module CoreExtensions
    module Response
      def html?
        # some versions of Rails integration tests don't set content type
        # so we are treating nil as html. A better fix would be welcome here.
        (content_type.respond_to?(:html?) ?
          content_type.html? : content_type =~ %r{^text/html}) ||
          content_type.nil?
      end
    end
  end
end
