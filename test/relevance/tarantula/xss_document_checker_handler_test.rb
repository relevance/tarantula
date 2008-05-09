require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::XssDocumentCheckerHandler" do
  before do
    @handler = Relevance::Tarantula::XssDocumentCheckerHandler.new([{'name' => 'foo_name', 'code' => 'foo_code', 'desc' => 'foo_desc'}])
  end
  
  it "detects the supplied code" do
    # @handler.expects(:queue_link).never
    result = @handler.handle(Result.new(:response => stub(:html? => true, :body => '<a href="/foo">foo_code</a>')))
    result.success.should == false
  end
end
