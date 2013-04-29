require 'socket'
require 'faraday'

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

      Faraday.new( config )
    end
  end

end