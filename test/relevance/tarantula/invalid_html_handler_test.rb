require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::InvalidHtmlHandler" do
  before do
    @handler = Relevance::Tarantula::InvalidHtmlHandler.new
  end
  
  it "rejects unclosed html" do
    response = stub(:html? => true, :body => '<html><div></html>', :code => 200)
    @handler.handle(nil, nil, response, nil).success.should == false
  end

  it "loves the good html" do
    response = stub(:html? => true, :body => '<html><div></div></html>', :code => 200)
    @handler.handle(nil, nil, response, nil).should == nil
  end

  it "ignores non html" do
    response = stub(:html? => false,  
                    :body => '<html><div></html>', 
                    :code => 200)
    @handler.handle(nil, nil, response, nil).should == nil
  end
end

