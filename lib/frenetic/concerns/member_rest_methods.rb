require 'active_support/concern'

class Frenetic
  module MemberRestMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def find(params)
        fail ResourceNotFound.new(self, params) if params.blank?
        params = { id:params } unless params.is_a?(Hash)
        return as_mock(params) if test_mode?
        fetch_resource(params)
      end

      def find_by!(params)
        find(params)
      end

      def find_by(params)
        find_by!(params)
      rescue ClientError
        nil
      end

      def all(*params)
        return [] if test_mode?
        response = api.get(collection_url(*params))
        Frenetic::ResourceCollection.new(self, response.body) if response.success?
      end

    private

      def fetch_resource(params)
        begin
          response = api.get(member_url(params))
        rescue ClientParsingError, ClientError => ex
          raise if ex.status != 404
          raise ResourceNotFound.new(self, params)
        end
        new(response.body) if response.success?
      end
    end
  end
end
