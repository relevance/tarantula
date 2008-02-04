require File.join(File.dirname(__FILE__), "..", "test_helper.rb")

describe "Relevance::Tarantula" do
  include Relevance::Tarantula
  before do
    @verbose = ENV['VERBOSE']
  end
  
  after do
    ENV['VERBOSE'] = @verbose
  end
  
  it "writes to stdout if ENV['VERBOSE']" do
    ENV['VERBOSE'] = "yep"
    expects(:puts).with("foo")
    log("foo")
  end

  it "swallows output if !ENV['VERBOSE']" do
    ENV['VERBOSE'] = nil
    expects(:puts).never
    log("foo")
  end
  
  it "puts RAILS_ROOT behind a method call" do
    lambda{rails_root}.should.raise(NameError).message.should == "uninitialized constant RAILS_ROOT"
  end
end

