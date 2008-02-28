class SafeString < String
  def to_s
    self
  end
  def to_s_xss_protected
    self
  end
end

class String
  def mark_as_xss_protected
    SafeString.new(self)
  end
end

class NilClass
  def mark_as_xss_protected
    self
  end
end

# ERB::Util.h and (include ERB::Util; h) are different methods
module ERB::Util
  class <<self
    def h_with_xss_protection(*args)
      h_without_xss_protection(*args).mark_as_xss_protected
    end
    alias_method_chain :h, :xss_protection
  end
  
    def h_with_xss_protection(*args)
      h_without_xss_protection(*args).mark_as_xss_protected
    end
    alias_method_chain :h, :xss_protection
end

class Object
  def to_s_xss_protected
    ERB::Util.h(to_s).mark_as_xss_protected
  end
end

class Array
  def join_xss_protected(sep="")
    map(&:to_s_xss_protected).join(sep.to_s_xss_protected).mark_as_xss_protected
  end
end
