require "spec_helper"

describe "Relevance::CoreExtensions::File#extension" do
  it "should return the extension without the leading dot" do
    File.extension("foo.bar").should == "bar"
  end
end
