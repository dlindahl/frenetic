require 'frenetic/structure_registry/rebuilder'

class Frenetic
  class StructureRegistry
    class Retriever
      def initialize(signatures, resource, attributes, key, rebuilder_class: Rebuilder)
        if key.blank?
          raise ArgumentError, "When registering a resource structure, you must provide a non-blank key"
        end
        @signatures, @resource, @attributes, @key = signatures, resource, attributes, key
        @rebuilder_class = rebuilder_class
      end

      def call
        if expired?
          @rebuilder_class.new(@signatures, @resource, @attributes, @key, struct_signature).call
        else
          fetch_structure
        end
      end

      def expired?
        @signatures[@key] != struct_signature
      end

      def fetch_structure
        Struct.const_get(@key)
      end

      def struct_signature
        Digest::SHA1.hexdigest(@attributes.keys.sort.join(''))
      end
    end
  end
end
