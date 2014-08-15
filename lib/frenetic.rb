require 'socket'
require 'faraday'
require 'faraday_middleware'

require 'frenetic/version'
require 'frenetic/errors'
require 'frenetic/concerns/configurable'
require 'frenetic/concerns/briefly_memoizable'
require 'frenetic/middleware/hal_json'
require 'frenetic/resource'
require 'frenetic/resource_collection'

class Frenetic
  extend Forwardable
  include Configurable
  include BrieflyMemoizable

  def_delegators :connection, :delete, :get, :head, :options, :patch, :post, :put

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

  # Since Frenetic needs to frequently refer to the API design, the result of
  # this method is essentially cached, regardless of what caching middleware it
  # is configured with.
  #
  # It fully honors the HTTP Cache-Control headers that are returned by the API.
  #
  # If no Cache-Control header is returned, then the results are not memoized.
  def description
    if response = get( config.url.to_s ) and response.success?
      @description_age = cache_control_age(response.headers)
      response.body
    end
  end
  briefly_memoize :description

  def schema
    description['_embedded']['schema']
  end

private

  def cache_control_age( headers )
    if cache_age = headers['Cache-Control']
      age = cache_age.match(%r{max-age=(?<max_age>\d+)})[:max_age]
      Time.now + age.to_i
    else
      config.default_root_cache_age
    end
  end
end