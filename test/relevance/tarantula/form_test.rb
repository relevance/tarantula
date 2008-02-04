require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::Form" do
  before do
    @tag = HTML::Document.new(<<END)
<form action="/session" method="post">
  <input name="authenticity_token" type="hidden" value="1be0d07c6e13669a87b8f52a3c7e1d1ffa77708d" />
  <input id="email" name="email" size="30" type="text" />
  <input id="password" name="password" size="30" type="password" />
  <input id="remember_me" name="remember_me" type="checkbox" value="1" />
  <input name="commit" type="submit" value="Log in" />
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.find(:tag => 'form'))
  end
  
  it "has an action" do
    @form.action.should == "/session"
  end
  
  it "has a method" do
    @form.method.should == "post"
  end
  
end

describe "A Relevance::Tarantula::Form with a hacked _method" do
  before do
    @tag = HTML::Document.new(<<END)
<form action="/foo">
  <input name="authenticity_token" type="hidden" value="1be0d07c6e13669a87b8f52a3c7e1d1ffa77708d" />
  <input id="_method" name="_method" size="30" type="text" value="PUT"/>
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.find(:tag => 'form'))
  end

  it "has a method" do
    @form.method.should == "put"
  end
  
end