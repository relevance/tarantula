require File.join(File.dirname(__FILE__), "../..", "test_helper.rb")

describe "Relevance::Tarantula::Transform" do
  it "can do a simple replace" do
    t = Relevance::Tarantula::Transform.new(/\w/, ".")
    t["hello world"].should == "..... ....."
  end
  
  it "can do a replace with a block" do
    t = Relevance::Tarantula::Transform.new(/([aeiou])/, Proc.new {|value| value.upcase})
    t["hello world"].should == "hEllO wOrld"
  end

  # this is broken in Ruby?
  it "cannot access groups from a block, despite Ruby docs" do
    p = Proc.new {|value| $1.upcase}
    t = Relevance::Tarantula::Transform.new(/([aeiou])/, p)
    lambda {t["hello world"]}.should.raise(NoMethodError).message.should ==
                              "undefined method `upcase' for nil:NilClass"
  end
end