require 'active_support/inflector'

class Frenetic
  class Resource

    def api
      self.class.api
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

  end
end