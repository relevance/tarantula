unless ENV['DISABLE_XSS_SHIELD']
  puts "Loading XSS Shield"
  require 'xss_shield'
else
  class ::String
    def mark_as_xss_protected
      self
    end
  end

  class ::NilClass
    def mark_as_xss_protected
      self
    end
  end
end
