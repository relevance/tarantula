require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::HtmlReporter file output" do
  include Relevance::Tarantula
  before do
    FileUtils.mkdir_p(test_output_dir)
    Relevance::Tarantula::Result.next_number = 0
    @result = Relevance::Tarantula::Result.new(
                          true, 
                         "get", 
                         "/some-fairly-long-url/with/lots/of/trailing/goo", 
                         stub(:code => 200, :body => "<h1>header</h1>\n<p>text</p>"), 
                         "/some-referrer", 
                         "{:param1 => :value, :param2 => :another_value}")
    @index = File.join(test_output_dir, "index.html")
    FileUtils.rm_f @index
    @detail = File.join(test_output_dir, "1.html")
    FileUtils.rm_f @detail
  end
  
  it "creates a report based on tarantula results" do
    results = stub_everything(:successes => [@result], :failures => [@result])
    # ERB::Util.expects(:h).with(:foo).returns(:data_stub)
    Relevance::Tarantula::HtmlReporter.report(test_output_dir, results)
    File.should.exist @index
    File.should.exist @detail
  end

end

describe "Relevance::Tarantula::HtmlReporter output processing" do
  include Relevance::Tarantula
  def turn_off_report_output
    Relevance::Tarantula::HtmlReporter.stubs(:output)
  end
  
  before do
    turn_off_report_output
    @result = Relevance::Tarantula::Result.new(
                          true, 
                         "stub_method", 
                         "stub_url",
                         stub(:code => 200, :body => "stub_body"), 
                         "stub_referrer", 
                         "stub_data")
  end

  it "html escapes the data and body sections" do
    @results = stub_everything(:successes => [], :failures => [@result])
    ERB::Util.expects(:h).with("stub_data")
    ERB::Util.expects(:h).with("stub_body")
    Relevance::Tarantula::HtmlReporter.report(test_output_dir, @results)
  end
end