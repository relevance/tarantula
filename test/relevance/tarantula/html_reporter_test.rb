require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::HtmlReporter" do
  include Relevance::Tarantula
  before do
    FileUtils.mkdir_p(test_output_dir)
    Result.next_number = 0
  end
  
  it "creates a report based on tarantula results" do
    index = File.join(test_output_dir, "index.html")
    FileUtils.rm_f index
    r = Result.new(true, 
                   "get", 
                   "/some-fairly-long-url/with/lots/of/trailing/goo", 
                   200, 
                   "/some-referrer", 
                   {:param1 => :value, :param2 => :another_value})
    results = stub_everything(:successes => [], :failures => [r])
    Relevance::Tarantula::HtmlReporter.report(test_output_dir, results)
    File.should.exist index
  end
  
end

