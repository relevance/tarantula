require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::HtmlDocumentHandler" do
  before do
    @handler = Relevance::Tarantula::HtmlDocumentHandler.new(nil)
  end
  
  it "does not write HTML Scanner warnings to the console" do
    bad_html = "<html><div></form></html>"    
    err = Recording.stderr do
      @handler.handle(Result.new(:response => stub(:html? => true, :body => bad_html)))
    end
    err.should == ""
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
    @handler.expects(:queue_form).with{|tag,referrer| Hpricot::Elem === tag}
    @handler.handle(Result.new(:response => stub(:html? => true, :body => '<form>stuff</form>')))
  end
  
  it "infers form action from page url if form is not explicit" do
    @handler.expects(:queue_form).with{|tag,referrer| tag['action'].should == '/page-url'; true }
    @handler.handle(Result.new(:url => "/page-url", :response => stub(:html? => true, :body => '<form>stuff</form>')))
  end
end

