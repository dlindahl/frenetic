require 'socket'
require 'faraday'
require 'faraday_middleware'

require 'frenetic/concerns/configurable'
require 'frenetic/middleware/hal_json'
require 'frenetic/resource'
require 'frenetic/resource_collection'
require 'frenetic/version'

class Frenetic
  extend Forwardable
  include Configurable

  def_delegators :connection, :get, :put, :post, :delete

  Error           = Class.new(StandardError)
  ConfigError     = Class.new(Error)
  ClientError     = Class.new(Error)
  ServerError     = Class.new(Error)
  ParsingError    = Class.new(Error)
  HypermediaError = Class.new(Error)

  def connection
    @connection ||= begin
      validate_configuration!

      Faraday.new( config ) do |builder|
        configure_authentication builder

        builder.response :hal_json

        configure_caching builder

        @builder_config.call( builder ) if @builder_config

        builder.adapter config.adapter
      end
    end
  end

  # It is highly advised that the server responds with some cache headers and
  # the API Client is configured to use a Faraday caching strategy
  def description
    if response = get( config.url.to_s ) and response.success?
      response.body
    end
  end

  def schema
    description['_embedded']['schema']
  end

end