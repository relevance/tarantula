# Run from your Rails main directory
require 'test/test_helper'

class TestHelpers < Test::Unit::TestCase
  def setup
    @base = ActionView::Base.new
  end

  def assert_haml_renders(expected, input)
    actual = Haml::Engine.new(input).to_html(@base)
    assert_equal expected, actual
  end

  def test_link_to
    assert_haml_renders <<OUT, <<IN
<a href="/bar">Foo</a>
<a href="/bar">Foo &amp; Bar</a>
<a href="/bar">Foo & Bar</a>
OUT
= link_to "Foo", "/bar"
= link_to "Foo & Bar", "/bar"
= link_to "Foo & Bar".mark_as_xss_protected, "/bar"
IN
  end
end
