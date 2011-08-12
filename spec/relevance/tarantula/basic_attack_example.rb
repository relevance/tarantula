require File.dirname(__FILE__) + "/../../example_helper.rb"

describe Relevance::Tarantula::BasicAttack do
  before do
    @attack = Relevance::Tarantula::BasicAttack.new
  end
  
  it "can generate a random whole number" do
    @attack.random_whole_number.should >= 0
    Fixnum.should === @attack.random_whole_number
  end
end