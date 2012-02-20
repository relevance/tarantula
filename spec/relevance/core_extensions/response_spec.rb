require "spec_helper"

describe "Relevance::CoreExtensions::Response#html?" do
  before do
    @response = OpenStruct.new
    @response.extend(Relevance::CoreExtensions::Response)
  end

  context 'when content_type is a String (Rails 2)' do
    it "should be html if the content-type is 'text/html'" do
      @response.content_type = "text/html"
      @response.should be_html
      @response.content_type = "text/html;charset=iso-8859-2"
      @response.should be_html
    end

    it "should not be html if the content-type isn't an html type" do
      @response.content_type = "text/plain"
      @response.should_not be_html
      @response.content_type = "application/pdf"
      @response.should_not be_html
    end
  end

  context 'when content_type is a Mime::Type (Rails 3)' do
    it "should be html if the content-type is 'text/html'" do
      @response.content_type = Mime::Type.new("text/html")
      @response.should be_html
      @response.content_type = Mime::Type.new("text/html;charset=iso-8859-2")
      @response.should be_html
    end

    it "should not be html if the content-type isn't an html type" do
      @response.content_type = Mime::Type.new("text/plain")
      @response.should_not be_html
      @response.content_type = Mime::Type.new("application/pdf")
      @response.should_not be_html
    end
  end

  # better ideas welcome, but be careful not to
  # castrate tarantula for proxies that don't set the content-type
  it "should pretend we have html if the content-type is nil" do
    @response.content_type = nil
    @response.should be_html
  end

end
