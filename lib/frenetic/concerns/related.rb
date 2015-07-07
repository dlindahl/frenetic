require 'active_support/core_ext/array/wrap'

class Frenetic
  module Related
    extend Frenetic::StructureMethodDefiner

    structure do |resource|
      resource.send(:relations).each do |relation, props|
        define_method(relation) do
          resource.fetch_related_resource(relation, props)
        end
      end
    end

    def extract_related_resources
      links.each do |k, attrs|
        next if k == 'self'
        Array.wrap(attrs).each do |relation|
          relations[k] = relation
        end
      end
    end

    def fetch_related_resource(relation, props)
      begin
        response = api.get(props['href'])
      rescue ClientParsingError, ClientError => ex
        raise if ex.status != 404
        raise ResourceNotFound.new(self, props)
      end
      return nil unless response.success?
      resource_class = self.class.find_resource_class(relation)
      if collection?(relation)
        self.class.extract_embedded_resources(response.body).fetch(relation, [])
      else
        resource_class.new(response.body)
      end
    end

  private

    def collection?(relation)
      relation != relation.singularize
    end

    def relations
      @_relations ||= {}
    end

    def schema
      api.description.fetch('_embedded', {}).fetch('schema', {})
    end
  end
end
