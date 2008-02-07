# dynamically mixed in to response objects
module Relevance::CoreExtensions::Response 
  def html?
    content_type == "text/html"
  end
end

