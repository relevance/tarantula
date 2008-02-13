require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::Result" do
  before do
    @result = Relevance::Tarantula::Result.new(true, 
                                              "get", 
                                              "/some/url?arg1=foo&arg2=bar", 
                                              nil, nil, nil)
  end
  
  it "has a short description" do
    @result.short_description.should == "get /some/url?arg1=foo&arg2=bar"
  end
  
  it "has a sequence number" do
    @result.class.next_number = 0
    @result.sequence_number.should == 1
    @result.class.next_number.should == 1
  end
  
end

describe "Relevance::Tarantula::Result class methods" do
  before do
    @rh = Relevance::Tarantula::Result
  end
  
  it "defines HTTP responses that are considered 'successful' when spidering" do
    %w{200 201 302 401}.each do |code|
      @rh.successful?(stub(:code => code)).should == true
    end
  end
  
  it "adds successful responses to success collection" do
    stub = stub_everything(:code => "200")
    @rh.handle(stub, stub, stub, stub).success.should == true
  end

  it "adds failed responses to failure collection" do
    stub = stub_everything(:code => "500")
    @rh.handle(stub, stub, stub, stub).success.should == false
  end
  
  it "passes arguments through to results object" do
    stub = stub_everything(:code => "500")
    response = stub(:code => 200)
    Relevance::Tarantula::Result.expects(:new).with(false,1,2,response,4,5)
    @rh.handle(1,2,response,4,5)
  end

end

