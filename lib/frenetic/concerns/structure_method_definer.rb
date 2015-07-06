class Frenetic
  module StructureMethodDefiner
    def structure
      @_structure_block = Proc.new if block_given?
    end
  end
end
