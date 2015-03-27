require 'active_support/concern'

require 'frenetic/hypermedia_link_set'

class Frenetic
  module HalLinked
    extend ActiveSupport::Concern

    def links
      @params['_links']
    end

    def member_url(params = {})
      resource = @resource_type || self.class.to_s.demodulize.underscore
      link = links[resource] || links['self']
      fail MissingResourceUrl.new(resource) if !link
      HypermediaLinkSet.new(link).href params
    end

    module ClassMethods
      def links
        api.description['_links']
      end

      def member_url(params = {})
        link = links[namespace]
        fail MissingResourceUrl.new(namespace) if !link
        HypermediaLinkSet.new(link).href params
      end

      def collection_url
        link = links[namespace.pluralize]
        fail MissingResourceUrl.new(namespace.pluralize) if !link
        HypermediaLinkSet.new(link).href
      end
    end
  end
end
