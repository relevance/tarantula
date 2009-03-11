if RUBY_VERSION == "1.8.7" # fix interaction between Ruby 187 and Rails 202, so we can at least run the test suite on that combination
  unless '1.9'.respond_to?(:force_encoding)
    String.class_eval do
      begin
        remove_method :chars
      rescue NameError
        # OK
      end
    end
  end
end