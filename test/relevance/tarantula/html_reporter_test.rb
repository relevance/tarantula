require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::HtmlReporter" do
  before do
    FileUtils.mkdir_p(test_output_dir)
  end
  
  it "creates a report based on tarantula results" do
    index = File.join(test_output_dir, "index.html")
    FileUtils.rm_f index
    results = stub_everything(:successes => [], :failures => [])
    Relevance::Tarantula::HtmlReporter.report(test_output_dir, results)
    File.should.exist index
  end
  
end

