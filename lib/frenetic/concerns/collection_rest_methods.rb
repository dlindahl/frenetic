require 'active_support/concern'

class Frenetic
  module CollectionRestMethods
    extend ActiveSupport::Concern

    def get(id)
      response = api.get(member_url(id))
      @resource_class.new(response.body) if response.success?
    end
  end
end
