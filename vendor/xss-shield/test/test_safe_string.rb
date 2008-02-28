# Run from your Rails main directory
require 'test/test_helper'

class TestSafeString < Test::Unit::TestCase
  def test_safe_string
    assert_equal "foo", "foo".to_s_xss_protected
    assert_equal "foo &amp; bar", "foo & bar".to_s_xss_protected
    assert_equal "foo &amp; bar", "foo & bar".to_s_xss_protected
    assert_equal "foo &amp;amp; bar", "foo &amp; bar".to_s_xss_protected
    assert_equal "foo &amp; bar", "foo & bar".to_s_xss_protected.to_s_xss_protected
    assert_equal "foo &amp; bar", h("foo & bar").to_s_xss_protected
    assert_equal "foo &amp;amp; bar", h(h("foo & bar"))
    
    assert_not_equal "foo".mark_as_xss_protected.object_id, "foo".mark_as_xss_protected.object_id
    x = "foo & bar".mark_as_xss_protected
    assert_equal x.mark_as_xss_protected, x
    # Not sure if this makes sense
    assert_not_equal x.mark_as_xss_protected.object_id, x.object_id

    assert_equal x.to_s, x
    assert_equal x.to_s.object_id, x.object_id
  end
  
  def test_nonstring_objects
    assert_equal "15", 15.to_s_xss_protected
    assert_equal SafeString, 15.to_s_xss_protected.class
  end
  
  def test_nil
    assert_equal "", nil.to_s_xss_protected
    assert_equal SafeString, nil.to_s_xss_protected.class
    assert_equal nil, nil.mark_as_xss_protected
  end
  
  def test_join
    assert_equal "", [].join_xss_protected
    assert_equal "", [].join_xss_protected(",")
    assert_equal "a", ["a"].join_xss_protected
    assert_equal "a", ["a"].join_xss_protected(",")
    assert_equal "ab", ["a", "b"].join_xss_protected
    assert_equal "a,b", ["a", "b"].join_xss_protected(",")

    assert_equal "a&amp;b", ["a", "b"].join_xss_protected("&")
    assert_equal "a&amp;amp;b", ["a", "b"].join_xss_protected("&amp;")
    assert_equal "a&amp;b", ["a", "b"].join_xss_protected("&amp;".mark_as_xss_protected)

    assert_equal "&lt;&amp;&gt;", ["<", ">"].join_xss_protected("&")
    assert_equal "&lt;&amp;amp;&gt;", ["<", ">"].join_xss_protected("&amp;")
    assert_equal "&lt;&amp;&gt;", ["<", ">"].join_xss_protected("&amp;".mark_as_xss_protected)

    assert_equal "< &amp; &gt;", ["<".mark_as_xss_protected, ">"].join_xss_protected(" & ")
    assert_equal "&lt; &amp; >", ["<", ">".mark_as_xss_protected].join_xss_protected(" & ")
    assert_equal "&lt; & &gt;", ["<", ">"].join_xss_protected(" & ".mark_as_xss_protected)
  end
end
