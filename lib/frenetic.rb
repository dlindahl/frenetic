require 'socket'
require 'faraday'
require 'faraday_middleware'
require 'active_support/configurable'
require 'active_support/core_ext/hash/reverse_merge'

require 'frenetic/version'
require 'frenetic/errors'
require 'frenetic/behaviors'
require 'frenetic/briefly_memoizable'
require 'frenetic/connection'
require 'frenetic/middleware/hal_json'
require 'frenetic/resource'
require 'frenetic/resource_collection'

require 'frenetic/structure_registry'

class Frenetic
  extend Forwardable
  include ActiveSupport::Configurable
  include BrieflyMemoizable

  MaxAge = /max-age=(?<max_age>\d+)/

  config_accessor :adapter
  config_accessor :api_token
  config_accessor :cache
  config_accessor :default_root_cache_age
  config_accessor :headers
  config_accessor :middleware
  config_accessor :password
  config_accessor :ssl
  config_accessor :test_mode
  config_accessor :url
  config_accessor :username

  def_delegators :connection, :delete, :get, :head, :options, :patch, :post, :put
  def_delegators :structure_registry, :construct

  # Can't explicitly use config_accessor because we need defaults and
  # ActiveSupport < 4 does not support them
  @@defaults = {
    adapter: Faraday.default_adapter,
    api_token: nil,
    cache: false,
    default_root_cache_age: nil,
    headers: {
      accept: 'application/hal+json',
      user_agent: "Frenetic v#{Frenetic::VERSION}; #{Socket.gethostname}"
    },
    middleware: [],
    password: nil,
    ssl: { verify:true },
    test_mode: false,
    url: nil,
    username: nil
  }
  config.merge!(@@defaults)

  # PENDING: [ActiveSupport4] Remove merge with class defaults
  def initialize(cfg = {})
    config.merge!(cfg.reverse_merge(self.class.config))
    yield config if block_given?
  end

  def connection
    @connection ||= Connection.new(config)
  end

  # PENDING: [ActiveSupport4] Use super.
  def configure
    yield(config).tap { reset_connection! }
  end

  # Since Frenetic needs to frequently refer to the API design, the result of
  # this method is essentially cached, regardless of what caching middleware it
  # is configured with.
  #
  # It fully honors the HTTP Cache-Control headers that are returned by the API.
  #
  # If no Cache-Control header is returned, then the results are not memoized.
  def description
    response = get(config.url.to_s)
    return unless response.success?
    @description_age = cache_control_age(response.headers)
    response.body
  end
  briefly_memoize :description

  def schema
    description.fetch('_embedded', {}).fetch('schema')
  end

  def structure_registry
    @structure_registry ||= StructureRegistry.new
  end

  def reset_connection!
    @connection = nil
  end

private

  def cache_control_age(headers)
    cache_age = headers['Cache-Control']
    if cache_age
      age = cache_age.match(MaxAge)[:max_age]
      Time.now + age.to_i
    else
      config.default_root_cache_age
    end
  end
end
