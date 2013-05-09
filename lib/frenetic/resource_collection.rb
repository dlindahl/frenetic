require 'frenetic/concerns/hal_linked'
require 'frenetic/concerns/collection_rest_methods'

class Frenetic
  class ResourceCollection < Delegator
    include HalLinked
    include CollectionRestMethods

    def initialize( resource, params = {} )
      @resource_class = resource
      @resources      = []
      @params         = params

      extract_resources!
    end

    def resource_type
      @resource_type ||= @resource_class.to_s.demodulize.underscore
    end

    def collection_key
      @collection_key ||= resource_type.pluralize
    end

    def __getobj__
      @resources
    end

    def __setobj__
      @resources
    end

    def api
      @resources.first.api
    end

  private

    def extract_resources!
      @resources = @params['_embedded'][collection_key].collect do |resource|
        @resource_class.new resource
      end
    end

  end
end