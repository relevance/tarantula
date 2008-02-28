FIXME: THIS README IS NOT UP-TO-DATE.

This plugin provides XSS protection for views coded in HAML and RHTML.

ERB templates are sometimes used for HTML, and sometimes for
other kinds of languages (SQL, email templates, YAML etc.).
XSS Shield protects only those templates with .rhtml extension,
leaving templates with .erb extension unprotected.

=== Quick start ===

Assuming you're using HAML for all your templates.

* Install plugin.
* Edit all your layout files and change:
    = @content_for_layout
    = yield(:foo) # Foo being usually :js or :css
  to:
    = @content_for_layout.mark_as_xss_protected
    = yield(:foo).mark_as_xss_protected
* By this point your application should be runnanble,
  but might need some tweaking here and there to avoid potential
  double-escaping.

=== How it works ===

It works by subclassing String into SafeString.
When HAML engine seems a "= foo" fragment it check if result of executing "foo"
is a SafeString. If it is - it copies it to the output, if it's anything else
(String, Integer, nil and so on) it HTML-escapes it first.

To avoid double-escaping output of h is a SafeString, as is everything you
mark as XSS-protected.
  = h(@foo)
  = @foo # fully equivalent to h(@foo)
  = "X <br /> Y".mark_as_xss_protected

It would be cumbersome to require mark_as_xss_protected every time you use
some helper like render :partial or link_to, so some helpers are modified
to return SafeString.

  = render :partial => "foo"
  = link_to "Bar", :action => :bar

If you trust your helpers, make them as XSS-protected:

  module Some::Module
    mark_helpers_as_xss_protected :text_field, :check_box
  end

Because it is not possible to alter syntactic keywords like yield
or instance variables like @content_for_layout to mark them automatically
as secure, layout files need some manual tweaking.

=== Other template engines ===

If a templates uses some templating engine other than HAML or ERB,
or it uses ERB but has extension .erb not .rhtml, XSS Shield does not protect it.

However some helpers like link_to and button_to are patched by XSS Shield to
make them more secure, and this extra security will be there even when used
in an otherwise unprotected context.

For example with XSS shield
  link_to "A & B", "/foo"
will return (marked as safe):
  '<a href="/foo">A &amp; B</a>'
not (plain String):
  '<a href="/foo">A & B</a>'

Also - RHTML protection only works with default ERB engine (erb.rb from Ruby base).
If you use some alternative ERB engine it probably won't work.

Adding support for alternative templating engine should be relatively straightforward.
It's mostly a matter of changing to_s to to_s_xss_protected in a few places
in their source.
