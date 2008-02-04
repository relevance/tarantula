require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::ResultsHandler" do
  before do
    @rh = Relevance::Tarantula::ResultsHandler.new
  end
  
  it "defines HTTP responses that are considered 'successful' when spidering" do
    %w{200 201 302 401}.each do |code|
      @rh.successful?(stub(:code => code)).should == true
    end
  end
  
  it "adds successful responses to success collection" do
    stub = stub_everything(:code => "200")
    @rh.handle(stub, stub, stub)
    @rh.successes.size.should == 1
  end

  it "adds failed responses to failure collection" do
    stub = stub_everything(:code => "500")
    @rh.handle(stub, stub, stub)
    @rh.failures.size.should == 1
  end

end

