require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "example_helper.rb"))

describe Relevance::Tarantula::FormSubmission do
  
  describe "with a good form" do
    # TODO: add more from field types to this example form as needed
    before do
      @tag = Hpricot(%q{
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
      })
    end

    describe "crawl" do

      it "converts ActiveRecord::RecordNotFound into a 404" do
        (crawler = stub_everything).expects(:submit).raises(ActiveRecord::RecordNotFound)
        form = Relevance::Tarantula::FormSubmission.new(make_form(@tag.at('form'), crawler))
        response = form.crawl
        response.code.should == "404"
        response.content_type.should == "text/plain"
        response.body.should == "ActiveRecord::RecordNotFound"
      end
      
      it "submits the form and logs response" do
        doc = Hpricot('<form action="/action" method="post"/>')
        form = make_form(doc.at('form'))
        fs = Relevance::Tarantula::FormSubmission.new(form)
        form.crawler.expects(:submit).returns(stub(:code => "200"))
        fs.expects(:log).with("Response 200 for #{fs}")
        fs.crawl
      end
      
    end

    describe "with default attack" do
      before do
        @form = make_form(@tag.at('form'))
        @fs = Relevance::Tarantula::FormSubmission.new(@form)
      end
  
      it "can mutate text areas" do
        @fs.attack.stubs(:random_int).returns("42")
        @fs.mutate_text_areas(@form).should == {"comment" => "42"}
      end
  
      it "can mutate selects" do
        Hpricot::Elements.any_instance.stubs(:rand).returns(stub(:[] => "2006-stub"))
        @fs.mutate_selects(@form).should == {"foo[opened_on(1i)]" => "2006-stub"}
      end
  
      it "can mutate inputs" do
        @fs.attack.stubs(:random_int).returns("43")
        @fs.mutate_inputs(@form).should == {"commit"=>"43", "secret"=>"43", "email"=>"43"}
      end

      it "has a signature based on action and fields" do
        @fs.signature.should == ['/session', [
          "comment", 
          "commit", 
          "email", 
          "foo[opened_on(1i)]", 
          "secret"],
          @fs.attack.name]
      end
  
      it "has a friendly to_s" do
        @fs.to_s.should =~ %r{^/session post}
      end
    end
    
    describe "with a custom attack" do
      before do
        @form = make_form(@tag.at('form'))
        @attack = Relevance::Tarantula::Attack.new(:name => 'foo_name', 
                                                   :input => 'foo_code', 
                                                   :output => 'foo_code')
        @fs = Relevance::Tarantula::FormSubmission.new(@form, @attack)
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
        Relevance::Tarantula::FormSubmission.stubs(:attacks).returns([
          Relevance::Tarantula::Attack.new({:name => 'foo_name1', :input => 'foo_input', :output => 'foo_output'}),
          Relevance::Tarantula::Attack.new({:name => 'foo_name2', :input => 'foo_input', :output => 'foo_output'}),
        ])
        Relevance::Tarantula::FormSubmission.mutate(@form).size.should == 2
      end

      it "maps hash attacks to Attack instances" do
        saved_attacks = Relevance::Tarantula::FormSubmission.instance_variable_get("@attacks")
        begin
          Relevance::Tarantula::FormSubmission.instance_variable_set("@attacks", [{ :name => "attack name"}])
          Relevance::Tarantula::FormSubmission.attacks.should == [Relevance::Tarantula::Attack.new({:name => "attack name"})]
        ensure
          # isolate this test properly
          Relevance::Tarantula::FormSubmission.instance_variable_set("@attacks", saved_attacks)
        end
      end
    end
  end
  
  describe "with a crummy form" do
    before do
      @tag = Hpricot(%q{
        <form action="/session" method="post">
          <input value="no_name" />
        </form>
      })
    end
    
    describe "with default attack" do
      before do
        @form = make_form(@tag.at('form'))
        @fs = Relevance::Tarantula::FormSubmission.new(@form)
      end

      it "ignores unnamed inputs" do
        @fs.mutate_inputs(@form).should == {}
      end
    end

    describe "with a custom attack" do
      before do
        @form = make_form(@tag.at('form'))
        @fs = Relevance::Tarantula::FormSubmission.new(@form, {:name => 'foo_name', :input => 'foo_code', :output => 'foo_code'})
      end

      it "ignores unnamed inputs" do
        @fs.mutate_inputs(@form).should == {}
      end
    end

  end
  
end
