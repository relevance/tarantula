raise "Haml not loaded" unless Haml::Engine.instance_method(:push_script)

module Haml
  class Engine
    def push_script(text, flattened)
      unless options[:suppress_eval]
        push_silent("haml_temp = #{text}", true)
        push_silent("haml_temp = haml_temp.to_s_xss_protected", true)
        out = "haml_temp = _hamlout.push_script(haml_temp, #{@output_tabs}, #{flattened})\n"
        if @block_opened
          push_and_tabulate([:loud, out])
        else
          @precompiled << out
        end
      end
    end

    def build_attributes(attributes = {})
      # We ignore @options[:attr_wrapper] because ERB::Util.h does not espace ' to &apos;
      # making ' as attribute quote not workable
      result = attributes.map do |a,v|
        v = v.to_s_xss_protected
        unless v.blank?
          " #{a}=\"#{v}\""
        end
      end
      result.sort.join
    end
  end

  class Buffer
    def build_attributes(attributes = {})
      result = attributes.map do |a,v|
        v = v.to_s_xss_protected
        unless v.blank?
          " #{a}=\"#{v}\""
        end
      end
      result.sort.join
    end
  end
end
