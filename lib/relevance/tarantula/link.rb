module Relevance
  module Tarantula

    class Link
      include Relevance::Tarantula

      class << self
        include ActionView::Helpers::UrlHelper
        # method_javascript_function needs this method
        def protect_against_forgery?
          false
        end
        #fast fix for rails3
        def method_javascript_function(method, url = '', href = nil)
          action = (href && url.size > 0) ? "'#{url}'" : 'this.href'
          submit_function =
            "var f = document.createElement('form'); f.style.display = 'none'; " +
            "this.parentNode.appendChild(f); f.method = 'POST'; f.action = #{action};"

          unless method == :post
            submit_function << "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); "
            submit_function << "m.setAttribute('name', '_method'); m.setAttribute('value', '#{method}'); f.appendChild(m);"
          end

          if protect_against_forgery?
            submit_function << "var s = document.createElement('input'); s.setAttribute('type', 'hidden'); "
            submit_function << "s.setAttribute('name', '#{request_forgery_protection_token}'); s.setAttribute('value', '#{escape_javascript form_authenticity_token}'); f.appendChild(s);"
          end
          submit_function << "f.submit();"
        end
      end

      METHOD_REGEXPS = {}
      [:put, :delete, :post, :patch].each do |m|
        # remove submit from the end so we'll match with or without forgery protection
        s = method_javascript_function(m).gsub( /f.submit();/, "" )
        # don't just match this.href in case a different url was passed originally
        s = Regexp.escape(s).gsub( /this.href/, ".*" )
        METHOD_REGEXPS[m] = /#{s}/
      end

      attr_accessor :href, :crawler, :referrer

      def initialize(link, crawler, referrer)
        @crawler, @referrer = crawler, referrer

        if String === link || link.nil?
          @href = transform_url(link)
          @meth = :get
        else # should be a tag
          @href = link['href'] ? transform_url(link['href'].downcase) : nil
          @tag = link
        end
      end

      def crawl
        response = crawler.follow(meth, href)
        log "Response #{response.code} for #{self}"
        crawler.handle_link_results(self, make_result(response))
      end

      def make_result(response)
        crawler.make_result(:method    => meth,
                            :url       => href,
                            :response  => response,
                            :referrer  => referrer)
      end

      def meth
        @meth ||= begin
                      (@tag &&
                       [:put, :delete, :post, :patch].detect do |m| # post should be last since it's least specific
                        @tag['onclick'] =~ METHOD_REGEXPS[m] ||
                        @tag['data-method'] == m.to_s.downcase
                       end) ||
                         :get
                    end
      end

      def transform_url(link)
        crawler.transform_url(link)
      end

      def ==(obj)
        obj.respond_to?(:href) && obj.respond_to?(:method) &&
          self.href.to_s == obj.href.to_s && self.meth.to_s == obj.meth.to_s
      end
      alias :eql? :==

        def hash
          to_s.hash
        end

      def to_s
        "<Relevance::Tarantula::Link href=#{href}, method=#{meth}>"
      end

    end

  end
end
