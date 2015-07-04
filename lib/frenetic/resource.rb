require 'delegate'
require 'ostruct'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

require 'frenetic/concerns/structured'
require 'frenetic/concerns/hal_linked'
require 'frenetic/concerns/member_rest_methods'
require 'frenetic/concerns/persistence'

class Frenetic
  class Resource < Delegator
    include Structured
    include HalLinked
    include MemberRestMethods
    include Persistence

    def self.api_client(client = nil)
      if client
        @api_client = client
      elsif block_given?
        @api_client = Proc.new
      elsif @api_client.is_a? Proc
        @api_client.call
      else
        @api_client
      end
    end

    # Alias class method hack
    def self.api
      api_client
    end

    def self.extract_embedded_resources(resource)
      resource.fetch('_embedded', {}).each_with_object({}) do |(resource_name, attrs), embeds|
        resource_class = find_resource_class(resource_name)
        if test_mode? && resource_class.respond_to?(:as_mock)
          embeds[resource_name] = resource_class.as_mock(attrs)
        elsif attrs.is_a?(Array)
          embeds[resource_name] = attrs.map do |a|
            resource_class.new(a)
          end
        else
          embeds[resource_name] = resource_class.new(attrs)
        end
      end
    end

    def self.find_resource_class(resource_name)
      class_namespace = self.to_s.deconstantize
      class_name = "#{class_namespace}::#{resource_name.classify}"
      begin
        class_name.constantize
      rescue NameError => ex
        raise if ex.message !~ /uninitialized constant/
        OpenStruct
      end
    end

    def self.namespace(namespace = nil)
      if namespace
        @namespace = namespace.to_s
      elsif @namespace
        @namespace
      else
        @namespace = to_s.demodulize.underscore
      end
    end

    def self.properties
      return mock_class.default_attributes if test_mode?
      props = (api.schema[namespace] || {})['properties']
      props || fail(MissingSchemaDefinition.new(namespace))
    end

    def self.mock_class
      @mock_class || fail(Frenetic::UndefinedResourceMock.new(namespace, self))
    end

    def self.as_mock(params = {})
      mock_class.new params
    end

    def initialize(params = {})
      @attrs = {}
      initialize_with(params)
    end

    def initialize_with(p)
      build_params(p)
      assign_attributes(@params)
      @attrs.merge!(self.class.extract_embedded_resources(@params))
      build_structure
    end

    def api_client
      self.class.api_client
    end
    alias_method :api, :api_client

    def assign_attributes(params)
      properties.keys.each do |k|
        @attrs[k] = params[k]
      end
    end

    def attributes
      @attributes ||= begin
        @structure.each_pair.each_with_object({}) do |(k, v), attrs|
          attrs[k.to_s] = v
        end
      end
    end

    def __getobj__
      @structure
    end

    def __setobj__(obj)
      @attributes = nil

      @structure = obj
    end

    def inspect
      attrs = attributes.collect do |k, v|
        val = v.is_a?(String) ? "\"#{v}\"" : v || 'nil'
        "#{k}=#{val}"
      end.join(' ')

      ivars = (instance_variables - [:@structure, :@attributes]).map do |k|
        val = instance_variable_get k
        val = val.is_a?(String) ? "\"#{val}\"" : val || 'nil'

        "#{k}=#{val}"
      end.join(' ')

      "#<#{self.class}:0x#{format('%x', object_id)}" \
        " #{attrs}" \
        " #{ivars}" \
      '>'
    end

  private

    def build_params(p)
      @params = (p || {}).with_indifferent_access
    end

    def build_structure
      @structure = structure.new(*@attrs.values)
    end

    def namespace
      self.class.namespace
    end

    def properties
      self.class.properties
    end

    def self.test_mode?
      !api_client || api_client.config.test_mode
    end
  end
end
