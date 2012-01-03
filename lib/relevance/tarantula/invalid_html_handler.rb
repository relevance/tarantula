module Relevance
  module Tarantula

    class InvalidHtmlHandler
      include Relevance::Tarantula
      def handle(result)
        response = result.response
        unless response.html?
          log "Skipping #{self.class} on url: #{result.url} because response is not html."
          return
        end
        begin
          body = HTML::Document.new(response.body, true)
        rescue Exception => e
          error_result = result.dup
          error_result.success = false
          error_result.description = "Bad HTML (Scanner)"
          error_result.data = e.message
          error_result
        else
          nil
        end
      end
    end

  end
end
