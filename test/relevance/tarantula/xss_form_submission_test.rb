require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::XssFormSubmission" do
  
  # TODO: add more from field types to this example form as needed
  before do
    @tag = Hpricot(<<END)
<form action="/session" method="post">
  <input id="email" name="email" size="30" type="text" />
  <textarea id="comment" name="comment"value="1" />
  <input name="commit" type="submit" value="Postit" />
  <input name="secret" type="hidden" value="secret" />
  <select id="foo_opened_on_1i" name="foo[opened_on(1i)]">
    <option value="2003">2003</option>
    <option value="2004">2004</option>
  </select> 
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.at('form'))
    @fs = Relevance::Tarantula::XssFormSubmission.new(@form, {'name' => 'foo_name', 'code' => 'foo_code', 'desc' => 'foo_desc'})
  end
  
  it "can mutate text areas" do
    @fs.mutate_text_areas(@form).should == {"comment" => "foo_code"}
  end
  
  it "can mutate selects" do
    Hpricot::Elements.any_instance.stubs(:rand).returns(stub(:[] => "2006-stub"))
    @fs.mutate_selects(@form).should == {"foo[opened_on(1i)]" => "2006-stub"}
  end
  
  it "can mutate inputs" do
    @fs.mutate_inputs(@form).should == {"commit"=>"foo_code", "secret"=>"foo_code", "email"=>"foo_code"}
  end

  it "has a signature based on action,  fields, and attack name" do
    @fs.signature.should == ['/session', [
      "comment", 
      "commit", 
      "email", 
      "foo[opened_on(1i)]", 
      "secret"],
      "foo_name"
    ]
  end
  
  it "has a friendly to_s" do
    @fs.to_s.should =~ %r{^/session post}
  end
  
  it "processes all its attacks" do
    Relevance::Tarantula::XssFormSubmission.attacks = [
      {'name' => 'foo_name1', 'code1' => 'foo_code1', 'desc' => 'foo_desc1'},
      {'name' => 'foo_name2', 'code2' => 'foo_code2', 'desc' => 'foo_desc2'},
    ]
    Relevance::Tarantula::XssFormSubmission.mutate(@form).size.should == 2
  end
end

describe "Relevance::Tarantula::XssFormSubmission for a crummy form" do
  before do
    @tag = Hpricot(<<END)
<form action="/session" method="post">
  <input value="no_name" />
</form>
END
    @form = Relevance::Tarantula::Form.new(@tag.at('form'))
    @fs = Relevance::Tarantula::XssFormSubmission.new(@form, {'name' => 'foo_name', 'code' => 'foo_code', 'desc' => 'foo_desc'})
  end
  
  it "ignores unnamed inputs" do
    @fs.mutate_inputs(@form).should == {}
  end
end
