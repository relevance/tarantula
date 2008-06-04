require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::XssDocumentCheckerHandler" do
  it "detects the supplied code" do
    @handler = Relevance::Tarantula::XssDocumentCheckerHandler.new
    attack = XssAttack.new({:name => 'foo_name', :input => 'foo_code', :output => 'foo_desc'})
    @handler.stubs(:attack).returns(attack)
    result = @handler.handle(Result.new(:response => stub(:html? => true, :body => '<a href="/foo">foo_code</a>')))
    result.success.should == false
  end
end
