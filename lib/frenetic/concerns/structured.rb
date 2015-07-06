class Frenetic
  module Structured
    # Stores the unique signature of each Resource Structure
    # Used to determine when a Structure has changed and thus
    # needs to be redefined.
    @@signatures = {}

    def struct_key
      "#{self.class}::FreneticResourceStruct".gsub '::', ''
    end

    def signature
      @attrs.keys.sort.join('')
    end

    def structure
      if structure_expired?
        rebuild_structure!
      else
        fetch_structure
      end
    end

    def fetch_structure
      Struct.const_get struct_key
    end

    def rebuild_structure!
      destroy_structure!
      @@signatures[struct_key] = signature
      Struct.new(struct_key, *@attrs.keys, &structure_instance_methods)
    end

    def structure_expired?
      @@signatures[struct_key] != signature
    end

    def structure_defined?
      Struct.constants.include? struct_key.to_sym
    end

    def destroy_structure!
      return unless structure_defined?
      @@signatures.delete struct_key
      Struct.send :remove_const, struct_key
    end

  private

    def structure_method_builders
      self.class.ancestors[1..-1].map do |ancestor|
        ancestor.instance_variable_get('@_structure_block')
      end.compact
    end

    def structure_instance_methods
      instance = self
      Proc.new do
        instance.send(:structure_method_builders).each do |builder|
          instance_exec(instance, &builder)
        end
      end
    end
  end
end
