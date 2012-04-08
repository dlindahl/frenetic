require 'faraday'

require "inker_directory_client/configuration"
require "inker_directory_client/version"
require "inker_directory_client/hal_json"

class InkerDirectoryClient
  extend Forwardable
  def_delegators :@connection, :get, :put, :post, :delete

  attr_reader  :connection
  alias_method :conn, :connection

  def initialize( config = {} )
    config = Configuration.new( config )

    @connection = Faraday.new( config ) do |builder|
      builder.use HalJson
      builder.adapter :net_http
    end
  end

  def schema
    @schema ||= load_schema
  end

private

  # TODO: Parse the root_uri from the config file.
  def load_schema
    if response = conn.get('/api/') and response.success?
      @schema = response.body
    end
  end
end
