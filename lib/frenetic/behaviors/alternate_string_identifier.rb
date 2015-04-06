# Allows a resource to be found by a string-based alternative key
#
# For example
#
# module MyClient
#   module MyResource < Frenetic::Resource
#     extend Frenetic::Behaviors::AlternateStringIdentifier
#
#     def self.find(id)
#       super(finder_params(id, :username))
#     end
#   end
# end
#
# Given an Api Schema such as:
#
# {
#   _links: {
#     my_resource: [{
#       { href: '/api/my_resource/{id}', rel: 'id' },
#       { href: '/api/my_resource/{username}?specific_to=username', rel: 'username' },
#     }]
#   }
# }
#
# MyClient::MyResource.find will choose the alternate link relation based on
# the string-based ID passed in.
#
# MyClient::MyResource.find(1)
# # Executes /api/my_resource/1
#
# MyClient::MyResource.find('100')
# # Executes /api/my_resource/100
#
# MyClient::MyResource.find('jdoe')
# Executes /api/my_resource/jdoe?specific_to=username
#
class Frenetic
  module Behaviors
    module AlternateStringIdentifier
      def finder_params(unique_id, alternate_key)
        return unique_id if unique_id.is_a? Hash
        params = {}
        key = nil
        if unique_id.to_i.to_s == unique_id.to_s
          key = :id
        elsif !unique_id.nil?
          key = alternate_key
        end
        params[key] = unique_id
        params
      end
    end
  end
end
