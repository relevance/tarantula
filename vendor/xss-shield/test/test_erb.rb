# Run from your Rails main directory
require 'test/test_helper'

class TestERB < Test::Unit::TestCase
  def assert_renders_erb(expected, input, shield=true)
    erb_class = shield ? XSSProtectedERB : ERB

    actual = eval(erb_class.new(input).src)
    
    assert_equal expected, actual
  end
  
  def test_erb_with_shield
    assert_renders_erb <<OUT, <<IN, true
Foo &amp;amp; Bar
Foo &amp;amp; Bar
Foo &amp; Bar
Foo &amp; Bar
Foo &amp; Bar
OUT
<%= "Foo &amp; Bar"  %>
<%= h("Foo &amp; Bar") %>
<%= "Foo &amp; Bar".mark_as_xss_protected  %>
<%= h("Foo & Bar") %>
<%= "Foo & Bar" %>
IN
  end
  
  def test_erb_without_shield
    assert_renders_erb <<OUT, <<IN, false
Foo &amp;amp; Bar
Foo &amp; Bar
Foo &amp; Bar
Foo &amp; Bar
Foo & Bar
OUT
<%= h("Foo &amp; Bar") %>
<%= "Foo &amp; Bar"  %>
<%= "Foo &amp; Bar".mark_as_xss_protected  %>
<%= h("Foo & Bar") %>
<%= "Foo & Bar" %>
IN
  end
end
