require 'addressable/template'
require 'active_support/core_ext/hash/indifferent_access'

class Frenetic
  class HypermediaLink

    def initialize( link )
      @link = link.with_indifferent_access
    end

    def href( tmpl_data = {} )
      if templated?
        expand tmpl_data
      else
        @link['href']
      end
    end
    alias :to_url :href

    def templated?
      return false unless hash?

      @link['templated'] == true
    end

    def expandable?( tmpl_data )
      return false unless templated?

      tmpl_data = normalize_data(tmpl_data)

      (template.variables & tmpl_data.keys.map(&:to_s)).size == template.variables.size
    end

    def template
      @template ||= Addressable::Template.new @link['href']
    end

    def as_json
      @link
    end

    def rel
      @link['rel']
    end

  private

    def expand( tmpl_data )
      tmpl_data = normalize_data(tmpl_data)

      return template.expand( tmpl_data ).to_s if expandable? tmpl_data

      raise Frenetic::HypermediaError,
              "The data provided could not satisfy the template requirements.\n" \
              "  Template: #{template.pattern}\n" \
              "  Data: #{tmpl_data}"
    end

    def hash?
      @link.is_a? Hash
    end

    def normalize_data( data )
      return data if data.is_a? Hash

      infer_template_values data
    end

    def infer_template_values( data )
      key = template.variables.first

      { key => data }
    end

  end
end