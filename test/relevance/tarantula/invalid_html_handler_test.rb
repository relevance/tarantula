require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::InvalidHtmlHandler" do
  before do
    @handler = Relevance::Tarantula::InvalidHtmlHandler.new
  end
  
  it "rejects unclosed html" do
    response = stub(:html? => true, :body => '<html><div></html>', :code => 200)
    result = @handler.handle(Result.new(:response => response))
    result.success.should == false
    result.description.should == "Bad HTML (Scanner)"
  end

  it "loves the good html" do
    response = stub(:html? => true, :body => '<html><div></div></html>', :code => 200)
    @handler.handle(Result.new(:response => response)).should == nil
  end

  it "ignores non html" do
    response = stub(:html? => false, :body => '<html><div></html>', :code => 200)
    @handler.handle(Result.new(:response => response)).should == nil
  end
end

