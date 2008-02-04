class Relevance::Tarantula::RailsIntegrationProxy
  include Relevance::Tarantula
  extend Forwardable
  attr_accessor :integration_test

  def initialize(integration_test)
    @integration_test = integration_test
    @integration_test.meta.attr_accessor :response
  end
  
  # TODO: generalize and handle all verbs
  def get(url, *args)
    integration_test.get(url, *args)
    response = integration_test.response
    check_for_static_version_of_404s(url, response)
    response
  end

  def post(url, *args)
    integration_test.post(url, *args)
    response = integration_test.response
    check_for_static_version_of_404s(url, response)
    response
  end

  def check_for_static_version_of_404s(url, response)
    if response.code == '404'
      if File.exist?(static_content_path(url))
        case ext = File.extension(url)
        when /jpe?g|gif|psd|png|eps|pdf/
          log "Skipping #{url} (for now)"
        when /html|te?xt|css|js/
          response.body = static_content_file(url)
          response.headers["type"] = "text/#{ext}"
          response.meta.attr_accessor :code
          response.code = "200"
        else
          log "Skipping unknown type #{url}"
        end
      end
    end
  end
  
  def static_content_file(url)
    File.read(static_content_path(url))
  end
  
  def static_content_path(url)
    File.expand_path(File.join(rails_root, "public", url))
  end
end
