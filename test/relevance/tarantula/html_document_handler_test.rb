require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::HtmlDocumentHandler" do
  before do
    @handler = Relevance::Tarantula::HtmlDocumentHandler.new(nil)
  end
  
  it "ignores non-html" do
    @handler.expects(:queue_link).never
    @handler.handle(Result.new(:response => stub(:html? => false, :body => '<a href="/foo">foo</a>')))
  end
  
  it "queues anchor tags" do
    @handler.expects(:queue_link).with("/foo", nil)
    @handler.handle(Result.new(:response => stub(:html? => true, :body => '<a href="/foo">foo</a>')))
  end

  it "queues link tags" do
    @handler.expects(:queue_link).with("/bar", nil)
    @handler.handle(Result.new(:response => stub(:html? => true, :body => '<link href="/bar">bar</a>')))
  end
  
  it "queues forms" do
    @handler.expects(:queue_form).with{|tag,referrer| HTML::Tag === tag}
    @handler.handle(Result.new(:response => stub(:html? => true, :body => '<form>stuff</form>')))
  end
  
  it "infers form action from page url if form is not explicit" do
    @handler.expects(:queue_form).with{|tag,referrer| tag['action'].should == '/page-url'; true }
    @handler.handle(Result.new(:url => "/page-url", :response => stub(:html? => true, :body => '<form>stuff</form>')))
  end
end

