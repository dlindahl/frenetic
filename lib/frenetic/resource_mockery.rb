require 'ostruct'
require 'delegate'
require 'active_support/concern'
require 'active_support/core_ext/hash/deep_merge'

class Frenetic
  module ResourceMockery
    extend Forwardable
    extend ActiveSupport::Concern

    def_delegators :@params, :to_json

    included do
      # I'm sure this violates some sort of CS principle or best practice,
      # but it solves the problem for now.
      superclass.send :instance_variable_set, '@mock_class', self
    end

    def attributes
      @params
    end

    def properties
      @params.each_with_object({}) do |(k, v), props|
        props[k] = v.class.to_s.underscore
      end
    end

    def default_attributes
      self.class.default_attributes
    end

    module ClassMethods
      def api_client
        superclass.api_client
      end

      # Provides a place for a Resources that are mocked to declare reasonable
      # default values for Mock Resources
      def default_attributes
        {}
      end
    end

  private

    def build_params(params)
      raw_params = (params || {}).with_indifferent_access
      defaults = default_attributes.with_indifferent_access
      @params = defaults.deep_merge(raw_params)
    end

    def build_structure
      @structure = OpenStruct.new(@attrs)
    end
  end
end
