require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::HtmlReporter file output" do
  include Relevance::Tarantula
  before do
    FileUtils.rm_rf(test_output_dir)
    FileUtils.mkdir_p(test_output_dir)
    Relevance::Tarantula::Result.next_number = 0
    @success_results = (1..10).map do |index|
      Relevance::Tarantula::Result.new(
        :success => true, 
        :method => "get", 
        :url => "/widgets/#{index}", 
        :response => stub(:code => 200, :body => "<h1>header</h1>\n<p>text</p>"), 
        :referrer => "/random/#{rand(100)}", 
        :log => <<-END,
Made-up stack trace:
/some_module/some_class.rb:697:in `bad_method'
/some_module/other_class.rb:12345677:in `long_method'
this link should be <a href="#">escaped</a>
blah blah blah
END
        :data => "{:param1 => :value, :param2 => :another_value}"
      )
    end
    @fail_results = (1..10).map do |index|
      Relevance::Tarantula::Result.new(
        :success => false, 
        :method => "get", 
        :url => "/widgets/#{index}", 
        :response => stub(:code => 500, :body => "<h1>header</h1>\n<p>text</p>"), 
        :referrer => "/random/#{rand(100)}", 
        :log => <<-END,
Made-up stack trace:
/some_module/some_class.rb:697:in `bad_method'
/some_module/other_class.rb:12345677:in `long_method'
this link should be <a href="#">escaped</a>
blah blah blah
END
        :data => "{:param1 => :value, :param2 => :another_value}"
      )
    end
    @index = File.join(test_output_dir, "index.html")
    FileUtils.rm_f @index
    @detail = File.join(test_output_dir, "1.html")
    FileUtils.rm_f @detail
  end
  
  it "creates a report based on tarantula results" do    
    Relevance::Tarantula::Result.any_instance.stubs(:rails_root).returns("STUB_ROOT")
    # results = stub(:successes => @results, :failures => @results)
    reporter = Relevance::Tarantula::HtmlReporter.new(test_output_dir)
    (@success_results + @fail_results).each {|r| reporter.report(r)}
    reporter.finish_report
    File.should.exist @index
    File.should.exist @detail
  end

end

