require "spec_helper"

describe "Relevance::Tarantula::Link" do
  include ActionView::Helpers::UrlHelper

  it "does not raise an error when initializing without href attribtue" do
    link = make_link(Hpricot('<a="/foo">foo</a>').at('a'))
    link.href.should == nil
    link.meth.should == :get
  end

  it "parses anchor tags" do
    link = make_link(Hpricot('<a href="/foo">foo</a>').at('a'))
    link.href.should == '/foo'
    link.meth.should == :get
  end

  it "parses anchor tags with POST 'method'" do
    link = make_link(Hpricot(%Q{<a href="/foo" onclick="#{Relevance::Tarantula::Link.method_javascript_function(:post)}">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.meth.should == :post
  end

  it "parses anchor tags with POST data-method" do
    link = make_link(Hpricot(%Q{<a href="/foo" data-method="post">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.meth.should == :post
  end

  it "parses anchor tags with PUT 'method'" do
    link = make_link(Hpricot(%Q{<a href="/foo" onclick="#{Relevance::Tarantula::Link.method_javascript_function(:put)}">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.meth.should == :put
  end

  it "parses anchor tags with PUT data-method" do
    link = make_link(Hpricot(%Q{<a href="/foo" data-method="put">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.meth.should == :put
  end

  it "parses anchor tags with PATCH data-method" do
    link = make_link(Hpricot(%Q{<a href="/foo" data-method="patch">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.meth.should == :patch
  end

  it "parses anchor tags with DELETE 'method'" do
    link = make_link(Hpricot(%Q{<a href="/foo" onclick="#{Relevance::Tarantula::Link.method_javascript_function(:delete)}">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.meth.should == :delete
  end

  it "parses anchor tags with DELETE data-method" do
    link = make_link(Hpricot(%Q{<a href="/foo" data-method="delete">foo</a>}).at('a'))
    link.href.should == '/foo'
    link.meth.should == :delete
  end

  it "parses link tags with text" do
    link = make_link(Hpricot('<link href="/bar">bar</a>').at('link'))
    link.href.should == '/bar'
    link.meth.should == :get
  end

  it "parses link tags without text" do
    link = make_link(Hpricot('<link href="/bar" />').at('link'))
    link.href.should == '/bar'
    link.meth.should == :get
  end

  it 'remembers link referrer if there is one' do
    link = make_link('/url', stub_everything, '/some-referrer')
    link.referrer.should == '/some-referrer'
  end

  it "does two things when crawled: follow, log, and handle" do
    crawler = Relevance::Tarantula::Crawler.new
    link = make_link('/foo', crawler)

    response = stub(:code => "200")
    crawler.expects(:follow).returns(response)
    link.expects(:log)
    crawler.expects(:handle_link_results)

    link.crawl
  end

  # method_javascript_function needs this method
  def protect_against_forgery?
    false
  end

end

describe "possible conflict when user has an AR model named Link" do
  it "does not taint Object with Relevance::Tarantula" do
    Object.ancestors.should_not include(Relevance::Tarantula)
  end

  it "doesnt break with a Link model" do
    lambda {
      class Link < ActiveRecord::Base
      end
    }.should_not raise_error
  end

end
