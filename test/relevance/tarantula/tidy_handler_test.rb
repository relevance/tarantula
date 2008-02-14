require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

if defined?(Tidy) && ENV['TIDY_PATH']
  describe "Relevance::Tarantula::TidyHandler default" do
    before do
      @handler = Relevance::Tarantula::TidyHandler.new
    end
  
    it "likes a good document" do
      response = stub(:html? => true, :body => <<-BODY, :code => 200)
<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 3.2//EN\">
<html>
  <title></title>
  <body></body>
</html>
BODY
      @handler.handle(nil, nil, response, nil).should == nil
    end

    it "rejects a document with errors" do
      response = stub(:html? => true, :body => "<hotml>", :code => 200)
      result = @handler.handle(nil, nil, response, nil)
      result.should.not.be nil
      result.data.should =~ /Error: <hotml> is not recognized!/
    end

    it "rejects a document with warnings" do
      response = stub(:html? => true, :body => <<-BODY, :code => 200)
<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 3.2//EN\">
<html>
</html>
BODY
      result = @handler.handle(nil, nil, response, nil)
      result.should.not.be nil
      result.data.should =~ /Warning: inserting missing 'title' element/
    end
    
  end
  
  describe "Relevance::Tarantula::TidyHandler with :show_warnings => false" do
    before do
      @handler = Relevance::Tarantula::TidyHandler.new(:show_warnings => false)
    end

    it "permits a document with warnings" do
      response = stub(:html? => true, :body => <<-BODY, :code => 200)
<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 3.2//EN\">
<html>
</html>
BODY
      result = @handler.handle(nil, nil, response, nil)
      result.should.be nil
    end
  end
else
  puts "TIDY_PATH not set. Tidy test will not run"
end
