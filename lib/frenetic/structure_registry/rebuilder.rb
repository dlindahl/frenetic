class Frenetic
  class StructureRegistry
    class Rebuilder
      attr_reader :signatures, :resource

      def initialize(signatures, resource, attributes, key, signature)
        @signatures, @resource, @attributes, @key, @signature = signatures, resource, attributes, key, signature
      end

      def call
        destroy!
        signatures[@key] = @signature
        Struct.new(@key, *@attributes.keys, &structure_instance_methods)
      end

      def destroy!
        return unless exists?
        signatures.delete(@key)
        Struct.send(:remove_const, @key)
      end

      def exists?
        Struct.constants.include?(@key.to_sym)
      end

    private

      def structure_instance_methods
        method_builders = resource.class.ancestors[1..-1].map do |ancestor|
          ancestor.instance_variable_get('@_structure_block')
        end.compact
        _resource = resource
        Proc.new do
          method_builders.each do |builder|
            instance_exec(_resource, &builder)
          end
        end
      end
    end
  end
end
