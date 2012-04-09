class Frenetic
  class HalJson < Faraday::Middleware
    # TODO: The API for this differs greatly from the `inspect` output.
    # Perhaps the Hash keys should be normalized and then aliased back to the original keys?
    class ResponseWrapper < RecursiveOpenStruct
      include Enumerable

      def []( key )
        self.send(key)
      end

      def members
        methods(false).grep(%r{_as_a_hash}).map { |m| m[0...-10] }
      end
      alias_method :keys, :members

      def each
        members.each do |method|
          yield method, send(method)
        end

        self
      end

      class << self
        # Do not define setters
        def define_setter( * ); end

        def define_getter( method_name, hash_key )
          method_name = case method_name
            when :_embedded then :resources
            when :_links    then :links
            when :href      then :url
            else method_name
            end

          super
        end
      end

    end
  end
end