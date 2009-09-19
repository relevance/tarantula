require File.expand_path(File.join(File.dirname(__FILE__), "../..", "example_helper.rb"))

describe Relevance::Tarantula::FileLoader do
  it "reads and evals the supplied file" do
    IO.expects(:read).with('some_file').returns("'foo'")
    result = Relevance::Tarantula::FileLoader.load_file('some_file')
    result.should == 'foo'
  end
  
  it "loads the file with the config module in scope" do
    IO.stubs(:read).returns('meta.ancestors')
    result = Relevance::Tarantula::FileLoader.load_file('some_file')
    result.should include(Relevance::Tarantula::Config)
  end

end