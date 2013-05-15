require 'active_support/concern'

# Memoizes method calls, but only for a specific period of time.
# Useful for supporting HTTP Cache-Control without an external caching layer
# like Rack::Cache
module BrieflyMemoizable
  extend ActiveSupport::Concern

  module ClassMethods
    def briefly_memoize( symbol )
      original_method = "_unmemoized_#{symbol}".to_sym
      memoized_ivar   = "@#{symbol}"
      age_ivar        = "@#{symbol}_age"

      class_eval <<-EOS
        if method_defined?(:#{original_method})                                  # if method_defined?(:_unmemoized_mime_type)
          raise "Already memoized #{symbol}"                                     #   raise "Already memoized mime_type"
        end                                                                      # end
        alias #{original_method} #{symbol}                                       # alias _unmemoized_mime_type mime_type

        def #{symbol}(*args)                                                     # def mime_type(*args)
          #{memoized_ivar} = nil if #{age_ivar} && Time.now > #{age_ivar}        #   @mime_type = nil if @mime_type_age && Time.now > @mime_type_age
                                                                                 #
          #{memoized_ivar} ||= #{original_method}(*args)                         #   @mime_type ||= _unmemoized_mime_type(*args)
        end                                                                      # end

        def reload_#{symbol}!                                                    # def reload_mime_type!
          #{memoized_ivar} = nil                                                 #   @mime_type = nil
        end                                                                      # end
      EOS
    end
  end

end