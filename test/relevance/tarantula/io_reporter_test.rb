require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe 'Relevance::Tarantula::IOReporter' do
  it "reports errors to stderr and then raises" do
    reporter = IOReporter.new($stderr)
    reporter.report stub(:code => "404", :url => "/uh-oh", :success => false)
    $stderr.expects(:puts).with("****** FAILURES")
    $stderr.expects(:puts).with("404: /uh-oh")
    lambda {reporter.finish_report("test_user_pages")}.should.raise RuntimeError
  end
end
