require 'active_support/concern'

class Frenetic
  module RestMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def find( id = nil )
        if response = api.get( member_url(id) ) and response.success?
          new response.body
        elsif response.status >= 500
          raise ServerError
        else
          raise ClientError
        end
      end
    end
  end
end