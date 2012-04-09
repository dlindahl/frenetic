class Frenetic
  class Resource

    attr_reader :links

    def initialize( attributes = {} )
      if attributes.is_a? Hash
        load attributes.keys, attributes

        @links = []
      else
        load self.class.schema, attributes
        load attributes.resources.members, attributes.resources

        @links = attributes.links
      end
    end

    # Attempts to retrieve the Resource Schema from the API based on the name
    # of the subclass.
    class << self
      def api_client( client = nil )
        metaclass.instance_eval do
          define_method :api do
            @api ||= block_given? ? yield : client
          end
        end
      end

      def schema
        if self.respond_to? :api
          class_name = self.to_s.split('::').last.downcase

          api.schema.resources.schema.send(class_name).properties
        else
          raise MissingAPIReference,
              "This Resource needs a class accessor defined as " +
              "`.api` that references an instance of Frenetic."
        end
      end

      def metaclass
        metaclass = class << self; self; end
      end
    end

  private

    def load( keys, attributes )
      keys.each do |key|
        instance_variable_set "@#{key}", attributes[key.to_s]

        # TODO: Ensure this is correct (and not need metaclass)
        self.class.class_eval do
        # metaclass.instance_eval do
          self.send :attr_reader, key
        end
      end
    end

  end
end