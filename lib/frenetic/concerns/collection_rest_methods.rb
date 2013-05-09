require 'active_support/concern'

class Frenetic
  module CollectionRestMethods
    extend ActiveSupport::Concern

    def get( id )
      if response = api.get( member_url(id) ) and response.success?
        @resource_class.new response.body
      end
    end
  end
end
