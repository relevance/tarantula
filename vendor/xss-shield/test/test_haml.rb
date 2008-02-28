# Run from your Rails main directory
require 'test/test_helper'

class TestHaml < Test::Unit::TestCase
  def setup
    @base = ActionView::Base.new
  end

  def assert_haml_renders(expected, input)
    actual = Haml::Engine.new(input).to_html(@base)
    assert_equal expected, actual
  end

  def test_haml_engine
    assert_haml_renders <<OUT, <<IN
A & B
C &amp; D
E &amp; F
G & H
I &amp; J
OUT
A & B
= "C & D"
= h("E & F")
= "G & H".mark_as_xss_protected
= "I & J".to_s_xss_protected
IN
  end
  
  def test_attribute_escaping_in_haml
    @base.instance_eval {
      @foo = "A < & > ' \" B"
    }
    assert_haml_renders <<OUT, <<IN
<div foo="A &lt; &amp; &gt; ' &quot; B" />
<div foo="A < & > ' " B" />
OUT
%div{:foo => @foo}/
%div{:foo => @foo.mark_as_xss_protected}/
IN
    # Note that '/" explicitly marked as XSS-protected can break validity
  end
end
