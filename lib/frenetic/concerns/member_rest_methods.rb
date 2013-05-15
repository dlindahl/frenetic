require 'active_support/concern'

class Frenetic
  module MemberRestMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def find( id = nil )
        if response = api.get( member_url(id) ) and response.success?
          new response.body
        end
      end

      def all
        if response = api.get( collection_url ) and response.success?
          Frenetic::ResourceCollection.new self, response.body
        end
      end
    end
  end
end