require 'ostruct'
require 'active_support/concern'

class Frenetic
  module ResourceMockery
    extend ActiveSupport::Concern

    included do
      # I'm sure this violates some sort of CS principle or best practice,
      # but it solves the problem for now.
      superclass.send :instance_variable_set, '@mock_class', self
    end

    def attributes
      @params
    end

    def properties
      @params.each_with_object({}) do |(k,v), props|
        props[k] = v.class.to_s.underscore
      end
    end

    # Provides a place for a Resources that are mocked to declare reasonable
    # default values for Mock Resources
    def default_attributes
      {}
    end

    module ClassMethods
      def api_client
        superclass.api_client
      end
    end

  private

    def build_params( p )
      defaults = default_attributes.with_indifferent_access
      @params  = defaults.merge( (p || {}).with_indifferent_access )
    end

    def build_structure
      @structure = OpenStruct.new( @attrs )
    end
  end
end