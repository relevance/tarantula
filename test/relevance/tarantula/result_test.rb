require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe "Relevance::Tarantula::Result" do
  before do
    @result = Relevance::Tarantula::Result.new(
        :success => true, 
        :method => "get", 
        :url => "/some/url?arg1=foo&arg2=bar"
    )
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
    @rh.handle(Result.new(:response => stub)).success.should == true
  end

  it "adds failed responses to failure collection" do
    stub = stub_everything(:code => "500")
    result = @rh.handle(Result.new(:response => stub))
    result.success.should == false
    result.description.should == "Bad HTTP Response"
  end
  
end

