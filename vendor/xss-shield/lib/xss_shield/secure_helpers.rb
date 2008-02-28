class Module
  def mark_helpers_as_xss_protected(*ms)
    ms.each do |m|
      begin
        instance_method("#{m}_with_xss_protection")
      rescue NameError
        define_method :"#{m}_with_xss_protection" do |*args|
          send(:"#{m}_without_xss_protection", *args).mark_as_xss_protected
        end
        alias_method_chain m, :xss_protection
      end
    end
  end
end

class ActionView::Base
  mark_helpers_as_xss_protected :javascript_include_tag,
                                :stylesheet_link_tag,
                                :render,
                                :text_field_tag,
                                :submit_tag,
                                :radio_button,
                                :text_area,
                                :auto_discovery_link_tag,
                                :image_tag

  def link_to_with_xss_protection(text, *args)
    link_to_without_xss_protection(text.to_s_xss_protected, *args).mark_as_xss_protected
  end
  alias_method_chain :link_to, :xss_protection

  def button_to_with_xss_protection(text, *args)
    button_to_without_xss_protection(text.to_s_xss_protected, *args).mark_as_xss_protected
  end
  alias_method_chain :button_to, :xss_protection
end

module ActionView::Helpers::FormHelper
  mark_helpers_as_xss_protected :text_field, :check_box
end
