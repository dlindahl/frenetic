require 'delegate'
require 'ostruct'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

require 'frenetic/concerns/structured'
require 'frenetic/concerns/hal_linked'
require 'frenetic/concerns/member_rest_methods'

class Frenetic
  class Resource < Delegator
    include Structured
    include HalLinked
    include MemberRestMethods

    def self.api_client( client = nil )
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
    def self.api; api_client; end

    def self.namespace( namespace = nil )
      if namespace
        @namespace = namespace.to_s
      elsif @namespace
        @namespace
      else
        @namespace = self.to_s.demodulize.underscore
      end
    end

    def self.properties
      (api.schema[namespace]||{})['properties'] or raise HypermediaError, %Q{Could not find schema definition for the resource "#{namespace}"}
    end

    def self.mock_class
      @mock_class or raise Frenetic::UndefinedResourceMock.new(namespace, self)
    end

    def self.as_mock( params = {} )
      mock_class.new params
    end

    def initialize( p = {} )
      build_params p
      @attrs  = {}

      properties.keys.each do |k|
        @attrs[k] = @params[k]
      end

      extract_embedded_resources

      build_structure
    end

    def api_client
      self.class.api_client
    end
    alias :api :api_client

    def attributes
      @attributes ||= begin
        @structure.each_pair.each_with_object({}) do |(k,v), attrs|
          attrs[k.to_s] = v
        end
      end
    end

    def __getobj__
      @structure
    end

    def __setobj__( obj )
      @attributes = nil

      @structure = obj
    end

    def inspect
      attrs = attributes.collect do |k,v|
        val = v.is_a?(String) ? "\"#{v}\"" : v || 'nil'
        "#{k}=#{val}"
      end.join(' ')

      ivars = (instance_variables - [:@structure, :@attributes]).map do |k|
        val = instance_variable_get k
        val = val.is_a?(String) ? "\"#{val}\"" : val || 'nil'

        "#{k}=#{val}"
      end.join(' ')

      "#<#{self.class}:0x#{"%x" % self.object_id}" \
        " #{attrs}" \
        " #{ivars}" \
      ">"
    end

  private

    def build_params( p )
      @params = (p || {}).with_indifferent_access
    end

    def extract_embedded_resources
      class_namespace = self.class.to_s.deconstantize

      @params.fetch('_embedded',{}).each do |k,v|
        class_name = "#{class_namespace}::#{k.classify}"
        klass      = class_name.constantize rescue OpenStruct

        @attrs[k] = if self.class.test_mode? || is_a?(ResourceMockery)
          klass.as_mock v
        else
          klass.new v
        end
      end
    end

    def build_structure
      @structure = structure.new( *@attrs.values )
    end

    def namespace
      self.class.namespace
    end

    def properties
      self.class.properties
    end

    def self.test_mode?
      api_client.config.test_mode
    end
  end
end