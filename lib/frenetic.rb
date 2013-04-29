require 'faraday'

require 'frenetic/version'

class Frenetic
  extend Forwardable
  def_delegators :connection, :get, :put, :post, :delete

  Error = Class.new(StandardError)

  def connection
    @connection ||= Faraday.new
  end
end