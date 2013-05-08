require 'active_support/concern'
require 'addressable/template'

class Frenetic
  module HalLinked
    extend ActiveSupport::Concern

    module ClassMethods
      def links
        api.description['_links']
      end

      def member_url( params = {} )
        url = links[namespace] or raise HypermediaError, %Q{No Hypermedia GET Url found for the resource "#{namespace}"}

        if url['templated']
          tmpl = Addressable::Template.new url['href']

          if params && !params.is_a?(Hash)
            params = infer_url_template_values tmpl, params
          end

          tmpl.expand( params ).to_s
        else
          url['href']
        end
      end

    private

      def infer_url_template_values( tmpl, params )
        key = tmpl.variables.first

        { key => params }
      end

    end
  end
end