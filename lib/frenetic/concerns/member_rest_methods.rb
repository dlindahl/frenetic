require 'active_support/concern'

class Frenetic
  module MemberRestMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def find(params)
        params = { id:params } unless params.is_a?(Hash)
        return as_mock(params) if test_mode?
        response = api.get(member_url(params))
        new(response.body) if response.success?
      end

      def all
        return [] if test_mode?
        response = api.get(collection_url)
        Frenetic::ResourceCollection.new(self, response.body) if response.success?
      end
    end
  end
end
