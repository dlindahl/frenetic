require 'active_support/configurable'
require 'active_support/concern'

require 'frenetic/configuration'

class Frenetic
  module Configurable
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Configurable
      # Don't allow the class to be configured
      class << self
        undef :configure
      end
    end

    def initialize( cfg = {} )
      config.merge! Frenetic::Configuration.new(cfg).attributes
      @builder_config = Proc.new if block_given?
    end

    def configure
      yield config
    end

  private

    def validate_configuration!
      raise( ConfigError, 'A URL must be defined' ) unless config.url
    end

    def configure_authentication( builder )
      if config.username
        builder.request :basic_auth, config.username, config.password
      end

      if config.api_token
        builder.request :token_auth, config.api_token
      end
    end

    def configure_caching( builder )
      if config.cache[:metastore]
        dependency 'rack-cache'
        builder.use FaradayMiddleware::RackCompatible, Rack::Cache::Context, config.cache
      end
    end

    def dependency( lib = nil )
      lib ? require(lib) : yield
    rescue NameError, LoadError => err
      raise ConfigError, "Missing dependency for #{self}: #{err.message}"
    end
  end
end