class XSSProtectedERB < ERB
  class Compiler < ::ERB::Compiler
    def compile(s)
      out = Buffer.new(self)

      content = ''
      scanner = make_scanner(s)
      scanner.scan do |token|
	if scanner.stag.nil?
	  case token
          when PercentLine
	    out.push("#{@put_cmd} #{content.dump}") if content.size > 0
	    content = ''
            out.push(token.to_s)
            out.cr
	  when :cr
	    out.cr
	  when '<%', '<%=', '<%#'
	    scanner.stag = token
	    out.push("#{@put_cmd} #{content.dump}") if content.size > 0
	    content = ''
	  when "\n"
	    content << "\n"
	    out.push("#{@put_cmd} #{content.dump}")
	    out.cr
	    content = ''
	  when '<%%'
	    content << '<%'
	  else
	    content << token
	  end
	else
	  case token
	  when '%>'
	    case scanner.stag
	    when '<%'
	      if content[-1] == ?\n
		content.chop!
		out.push(content)
		out.cr
	      else
		out.push(content)
	      end
	    when '<%='
              # NOTE: Changed lines
	      out.push("#{@insert_cmd}((#{content}).to_s_xss_protected)")
              # NOTE: End changed lines
	    when '<%#'
	      # out.push("# #{content.dump}")
	    end
	    scanner.stag = nil
	    content = ''
	  when '%%>'
	    content << '%>'
	  else
	    content << token
	  end
	end
      end
      out.push("#{@put_cmd} #{content.dump}") if content.size > 0
      out.close
      out.script
    end
  end

  def initialize(str, safe_level=nil, trim_mode=nil, eoutvar='_erbout')
    @safe_level = safe_level
    compiler = XSSProtectedERB::Compiler.new(trim_mode)
    set_eoutvar(compiler, eoutvar)
    @src = compiler.compile(str)
    @filename = nil
  end
end

module ActionView
  class Base
    private
      def create_template_source(extension, template, render_symbol, locals)
        if template_requires_setup?(extension)
          body = case extension.to_sym
            when :rxml, :builder
              content_type_handler = (controller.respond_to?(:response) ? "controller.response" : "controller")
              "#{content_type_handler}.content_type ||= Mime::XML\n" +
              "xml = Builder::XmlMarkup.new(:indent => 2)\n" +
              template +
              "\nxml.target!\n"
            when :rjs
              "controller.response.content_type ||= Mime::JS\n" +
              "update_page do |page|\n#{template}\nend"
          end
        # NOTE: Changed lines
        elsif extension.to_sym == :rhtml
          body = XSSProtectedERB.new(template, nil, @@erb_trim_mode).src
        # NOTE: End changed lines
        else
          body = ERB.new(template, nil, @@erb_trim_mode).src
        end

        @@template_args[render_symbol] ||= {}
        locals_keys = @@template_args[render_symbol].keys | locals
        @@template_args[render_symbol] = locals_keys.inject({}) { |h, k| h[k] = true; h }

        locals_code = ""
        locals_keys.each do |key|
          locals_code << "#{key} = local_assigns[:#{key}]\n"
        end

        "def #{render_symbol}(local_assigns)\n#{locals_code}#{body}\nend"
      end
  end
end
