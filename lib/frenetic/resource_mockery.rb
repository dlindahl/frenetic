require 'ostruct'
require 'delegate'
require 'active_support/concern'
require 'active_support/core_ext/hash/deep_merge'

class Frenetic
  module ResourceMockery
    extend Forwardable
    extend ActiveSupport::Concern

    def_delegators :@raw_params, :as_json, :to_json

    included do
      # I'm sure this violates some sort of CS principle or best practice,
      # but it solves the problem for now.
      superclass.send :instance_variable_set, '@mock_class', self
    end

    def attributes
      @known_attributes
    end

    def properties
      @known_attributes.each_with_object({}) do |(k, v), props|
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

    def _assign_attributes(attributes)
      defaults = default_attributes.with_indifferent_access
      @known_attributes = cast_types(defaults.deep_merge(@raw_attributes))
    end

    def build_structure
      @structure = OpenStruct.new(@known_attributes)
    end

    # A naive attempt to cast the attribute types of the incoming mock data
    # based on any available type information provided in :default_attributes
    def cast_types(params)
      default_attributes.each do |key, value|
        params[key] =
          case value
          when String then String(params[key])
          when Float then Float(params[key])
          when Integer then Integer(params[key])
          else params[key]
          end
      end
      params
    end
  end
end
