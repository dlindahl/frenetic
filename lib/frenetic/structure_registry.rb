require 'frenetic/structure_registry/retriever'

class Frenetic
  class StructureRegistry
    attr_reader :signatures

    def initialize(retriever_class: Frenetic::StructureRegistry::Retriever)
      @signatures = {}
      @retriever_class = retriever_class
    end

    def construct(resource, attributes, key)
      fetch(resource, attributes, key).new(*attributes.values)
    end

    def fetch(resource, attributes, key)
      @retriever_class.new(signatures, resource, attributes, key).call
    end
  end
end
