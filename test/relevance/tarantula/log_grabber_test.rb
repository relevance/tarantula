require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")
include Relevance::Tarantula

describe 'Relevance::Tarantula::LogGrabber' do
  before {@grabber = LogGrabber.new(log_file)}

  def log_file
    File.join(File.join(test_output_dir, "example.log"))
  end
  
  it "can clear the log file" do
    File.open(log_file, "w") {|f| f.puts "sample log"}
    File.size(log_file).should == 11  
    @grabber.clear!
    File.size(log_file).should == 0  
  end
  
  it "can grab the log file" do
    File.open(log_file, "w") {|f| f.puts "sample log"}
    @grabber.grab!.should == "sample log\n"
    File.size(log_file).should == 0
  end
  
end