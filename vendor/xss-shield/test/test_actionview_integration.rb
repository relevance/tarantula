# Run from your Rails main directory
require 'test/test_helper'

class TestActionViewIntegration < Test::Unit::TestCase
  def assert_renders(expected, input, extension)
    base = ActionView::Base.new
    actual = base.render_template(extension, input, "foo.#{extension}")
    assert_equal expected, actual
  end

  def test_erb
    assert_renders <<OUT, <<IN, :erb
A & B
A & B
OUT
<%= "A & B" %>
<%= "A & B".mark_as_xss_protected %>
IN
  end

  def test_rhtml
    assert_renders <<OUT, <<IN, :rhtml
A &amp; B
A & B
OUT
<%= "A & B" %>
<%= "A & B".mark_as_xss_protected %>
IN
  end
 
  def test_haml
    assert_renders <<OUT, <<IN, :haml
A &amp; B
A & B
OUT
= "A & B"
= "A & B".mark_as_xss_protected
IN
  end
end
