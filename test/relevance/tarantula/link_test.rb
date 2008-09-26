require File.join(File.dirname(__FILE__), "..", "..", "test_helper.rb")

describe "Relevance::Tarantula::Link" do
  include ActionView::Helpers::UrlHelper
  
  it "parses anchor tags" do
    link = Relevance::Tarantula::Link.new(Hpricot('<a href="/foo">foo</a>').at('a'))
    assert_equal "/foo", link.href
    assert_equal :get, link.method
  end

  it "parses anchor tags with POST 'method'" do
    link = Relevance::Tarantula::Link.new(Hpricot(%Q{<a href="/foo" onclick="#{method_javascript_function(:post)}">foo</a>}).at('a'))
    assert_equal "/foo", link.href
    assert_equal :post, link.method
  end

  it "parses anchor tags with PUT 'method'" do
    link = Relevance::Tarantula::Link.new(Hpricot(%Q{<a href="/foo" onclick="#{method_javascript_function(:put)}">foo</a>}).at('a'))
    assert_equal "/foo", link.href
    assert_equal :put, link.method
  end

  it "parses anchor tags with DELETE 'method'" do
    link = Relevance::Tarantula::Link.new(Hpricot(%Q{<a href="/foo" onclick="#{method_javascript_function(:delete)}">foo</a>}).at('a'))
    assert_equal "/foo", link.href
    assert_equal :delete, link.method
  end

  it "parses link tags with text" do
    link = Relevance::Tarantula::Link.new(Hpricot('<link href="/bar">bar</a>').at('link'))
    assert_equal "/bar", link.href
    assert_equal :get, link.method
  end
  
  it "parses link tags without text" do
    link = Relevance::Tarantula::Link.new(Hpricot('<link href="/bar" />').at('link'))
    assert_equal "/bar", link.href
    assert_equal :get, link.method
  end
  
  # method_javascript_function needs this method
  def protect_against_forgery?
    false
  end
  
end

describe "possible conflict when user has an AR model named Link" do
  it "does not taint Object with Relevance::Tarantula" do
    Object.ancestors.should.not.include Relevance::Tarantula
  end
  
  it "doesnt break with a Link model" do
    lambda {
      class Link < ActiveRecord::Base
      end
    }.should.not.raise
  end
  
end