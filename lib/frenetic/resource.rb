require 'active_support/inflector'

class Frenetic
  class Resource

    def initialize( attributes = {} )
      self.class.apply_schema

      attributes.each do |key, val|
        instance_variable_set "@#{key}", val
      end

      @_links ||= {}

      build_associations attributes
    end

    def links
      @_links
    end

    def attributes
      self.class.schema.keys.each_with_object({}) do |key, attrs|
        attrs[key] = public_send key
      end
    end
    alias_method :to_hash, :attributes

    # Attempts to retrieve the Resource Schema from the API based on the name
    # of the subclass.
    class << self
      def api_client( client = nil )
        metaclass.instance_eval do
          define_method :api do
            block_given? ? yield : client
          end
        end
      end

      def schema
        if self.respond_to? :api
          class_name = self.to_s.demodulize.underscore

          if class_schema = api.description.resources.schema.send(class_name)
            class_schema.properties
          else
            {}
          end
        else
          raise MissingAPIReference,
            "This Resource needs a class accessor defined as " \
            "`.api` that references an instance of Frenetic."
        end
      end

      def apply_schema
        schema.keys.each do |key|
          next if key[0] == '_'

          class_eval { attr_reader key.to_sym } unless instance_methods.include? key
          class_eval { attr_writer key.to_sym } unless instance_methods.include? "#{key}="
        end
      end

      def metaclass
        class << self; self; end
      end
    end

    def build_associations( attributes )
      return unless attributes['_embedded']

      namespace = self.class.to_s.deconstantize

      attributes['_embedded'].each do |key, value|
        self.class.class_eval do
          attr_reader key.to_sym
        end

        assoc_class = "#{namespace}::#{key.classify}"

        if assoc_class = (assoc_class.constantize rescue nil)
          value = assoc_class.new value
        end

        instance_variable_set "@#{key}", value
      end
    end

  end
end