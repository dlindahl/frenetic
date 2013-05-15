require 'addressable/uri'
require 'active_support/core_ext/hash/indifferent_access'

class Frenetic
  class Configuration

    @@defaults = {
      headers:   {
        accept:     'application/hal+json',
        user_agent: "Frenetic v#{Frenetic::VERSION}; #{Socket.gethostname}"
      }
    }

    def initialize( cfg = {} )
      @_cfg = cfg.symbolize_keys
    end

    def adapter
      @_cfg[:adapter] || Faraday.default_adapter
    end

    def api_token
      @_cfg[:api_token]
    end

    def attributes
      {
        adapter:   adapter,
        api_token: api_token,
        cache:     cache,
        default_root_cache_age: default_root_cache_age,
        headers:   headers,
        password:  password,
        ssl:       ssl,
        url:       url,
        username:  username
      }
    end

    def cache
      if @_cfg[:cache] == :rack
        {
          metastore:     'file:tmp/rack/meta',
          entitystore:   'file:tmp/rack/body',
          ignore_headers: %w{Authorization Set-Cookie X-Content-Digest}
        }
      else
        {}
      end
    end

    def default_root_cache_age
      @_cfg[:default_root_cache_age]
    end

    def headers
      @@defaults[:headers].merge( @_cfg[:headers] || {} ).tap do |h|
        if @_cfg[:headers] && @_cfg[:headers][:user_agent]
          if h[:user_agent] != @@defaults[:headers][:user_agent]
            h[:user_agent] = "#{h[:user_agent]} (#{@@defaults[:headers][:user_agent]})"
          end
        end
      end
    end

    def password
      @_cfg[:password] || @_cfg[:api_key]
    end

    def ssl
      @_cfg[:ssl] || { verify:true }
    end

    def url
      Addressable::URI.parse @_cfg[:url]
    end

    def username
      @_cfg[:username] || @_cfg[:app_id]
    end

  end
end