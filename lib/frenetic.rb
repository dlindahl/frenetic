require 'socket'
require 'faraday'
require 'faraday_middleware'

require 'frenetic/concerns/configurable'
require 'frenetic/version'

class Frenetic
  extend Forwardable
  include Configurable

  def_delegators :connection, :get, :put, :post, :delete

  Error       = Class.new(StandardError)
  ConfigError = Class.new(Error)

  def connection
    @connection ||= begin
      validate_configuration!

      Faraday.new( config ) do |builder|
        if config.username
          builder.request :basic_auth, config.username, config.password
        end

        if config.api_token
          builder.request :token_auth, config.api_token
        end

        if config.cache[:metastore]
          __require__ 'rack-cache'

          builder.use FaradayMiddleware::RackCompatible, Rack::Cache::Context, config.cache
        end

        @builder_config.call( builder ) if @builder_config

        builder.adapter config.adapter
      end
    end
  end

private

  def __require__( *args )
    require( *args )
  rescue LoadError => err
    raise ConfigError, "#{err.class} - #{err.message}. Install with `gem install #{args.first}`"
  end

end