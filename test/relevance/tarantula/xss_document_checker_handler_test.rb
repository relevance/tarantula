require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::XssDocumentCheckerHandler" do
  before do
    @handler = Relevance::Tarantula::XssDocumentCheckerHandler.new
    attack = XssAttack.new({:name => 'foo_name', :input => 'foo_code', :output => '<bad>'})
    @handler.stubs(:attacks).returns([attack])
  end
  
  it "lets safe documents through" do
    result = @handler.handle(Result.new(:response => stub(:html? => true, :body => '<a href="/foo">good</a>')))
    result.should == nil
  end
  
  it "detects the supplied code" do
    result = @handler.handle(Result.new(:response => stub(:html? => true, :body => '<a href="/foo"><bad></a>')))
    result.success.should == false
  end
end
