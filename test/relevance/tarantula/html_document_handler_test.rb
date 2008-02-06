require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::HtmlDocumentHandler" do
  before do
    @handler = Relevance::Tarantula::HtmlDocumentHandler.new(nil)
  end
  
  it "queues anchor tags" do
    @handler.expects(:queue_link).with("/foo", nil)
    @handler.handle nil, nil, stub(:body => '<a href="/foo">foo</a>'), nil
  end

  it "queues link tags" do
    @handler.expects(:queue_link).with("/bar", nil)
    @handler.handle nil, nil, stub(:body => '<link href="/bar">bar</a>'), nil
  end
  
  it "queues forms" do
    @handler.expects(:queue_form).with{|tag| HTML::Tag === tag}
    @handler.handle nil, nil, stub(:body => '<form>stuff</form>'), nil
  end
  
  it "infers form action from page url if form is not explicit" do
    @handler.expects(:queue_form).with{|tag| tag['action'].should == '/page-url'; true }
    @handler.handle nil, '/page-url', stub(:body => '<form>stuff</form>'), nil
  end
end

