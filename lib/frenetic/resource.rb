require 'delegate'
require 'active_support/inflector'
require 'active_support/core_ext/hash/indifferent_access'

require 'frenetic/concerns/structured'
require 'frenetic/concerns/hal_linked'
require 'frenetic/concerns/rest_methods'

class Frenetic
  class Resource < Delegator
    include Structured
    include HalLinked
    include RestMethods

    def api
      self.class.api
    end

    def self.api
      api_client
    end

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

    def self.namespace( namespace = nil )
      if namespace
        @namespace = namespace.to_s
      elsif @namespace
        @namespace
      else
        @namespace = self.to_s.demodulize.underscore
      end
    end

    def initialize( p = {} )
      @params = (p || {}).with_indifferent_access
      @attrs  = {}

      api_schema.keys.each do |k|
        @attrs[k] = @params[k]
      end

      @structure = structure.new( *@attrs.values )
    end

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

    def __setobj__
      @structure
    end

    def inspect
      attrs = @structure.each_pair.collect do |k,v|
        val = v.is_a?(String) ? "\"#{v}\"" : v || 'nil'
        "#{k}=#{val}"
      end.join(' ')

      ivars = (instance_variables - [:@structure]).map do |k|
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

    def namespace
      self.class.namespace
    end

    def api_schema
      (api.schema[namespace]||{})['properties'] or raise HypermediaError, %Q{Could not find schema definition for the resource "#{namespace}"}
    end

  end
end