require 'active_support/concern'

require 'frenetic/hypermedia_link_set'

class Frenetic
  module HalLinked
    extend ActiveSupport::Concern

    def links
      @params['_links']
    end

    def member_url( params = {} )
      resource = @resource_type || self.class.to_s.demodulize.underscore

      link = links[resource] || links['self'] or raise HypermediaError, %Q{No Hypermedia GET Url found for the resource "#{resource}"}

      HypermediaLinkSet.new( link ).href params
    end

    module ClassMethods
      def links
        api.description['_links']
      end

      def member_url( params = {} )
        link = links[namespace] or raise HypermediaError, %Q{No Hypermedia GET Url found for the resource "#{namespace}"}

        HypermediaLinkSet.new( link ).href params
      end

      def collection_url
        link = links[namespace.pluralize] or raise HypermediaError, %Q{No Hypermedia GET Url found for the resource "#{namespace.pluralize}"}

        HypermediaLinkSet.new( link ).href
      end

    end
  end
end