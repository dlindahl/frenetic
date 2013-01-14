require 'socket'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'

class Frenetic
  class Configuration

    @@defaults = {
      cache:    nil,
      url:      nil,
      username: nil,
      password: nil,
      headers:  {
        accept: 'application/hal+json'
      },
      request:  {},
      response: {}
    }

    attr_accessor :cache, :url, :username, :password
    attr_accessor :headers, :request, :response, :middleware

    def initialize( config = {} )
      config = @@defaults.deep_merge( config.symbolize_keys )

      map_api_key_to_username config
      append_user_agent       config
      filter_cache_headers    config

      config.each do |k, v|
        v.symbolize_keys! if v.is_a? Hash

        instance_variable_set "@#{k}", v
      end
    end

    def attributes
      validate!

      (instance_variables - [:@middleware]).each_with_object({}) do |k, attrs|
        key = k.to_s.gsub( '@', '' )

        value = instance_variable_get( k )

        attrs[key.to_sym] = value
      end
    end
    alias_method :to_hash, :attributes

    def validate!
      raise(Frenetic::ConfigurationError, 'No API URL defined!') unless @url.present?

      if @cache
        raise( ConfigurationError, 'No cache :metastore defined!' )               unless @cache[:metastore].present?
        raise( ConfigurationError, "No cache :entitystore defined!" )             unless @cache[:entitystore].present?
      end
    end

    def middleware
      @middleware ||= []
    end

    def use( *args )
      middleware << args
    end

  private

    def user_agent
      "Frenetic v#{Frenetic::VERSION}; #{Socket.gethostname}"
    end

    def map_api_key_to_username( config )
      if config[:api_key]
        if config[:app_id]
          config[:username] = config.delete :app_id
          config[:password] = config.delete :api_key
        else
          config[:username] = config.delete :api_key
        end
      end
    end

    def append_user_agent( config )
      if config[:headers][:user_agent]
        config[:headers][:user_agent] << " (#{user_agent})"
      else
        config[:headers][:user_agent] = user_agent
      end
    end

    def filter_cache_headers( config )
      if config[:cache]
        ignore_headers = config[:cache][:ignore_headers] || []

        config[:cache][:ignore_headers] = (ignore_headers + %w[Set-Cookie X-Content-Digest]).uniq
      end
    end

  end
end