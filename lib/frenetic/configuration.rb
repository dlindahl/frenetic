require 'socket'

class Frenetic
  class Configuration < Hash

    class ConfigurationError < StandardError; end

    # TODO: This is in desperate need of .with_indifferent_access...
    # TODO: "content-type" should probably be within a "headers" key
    def initialize( custom_config = {} )
      config = config_file.merge custom_config
      config = symbolize_keys config

      config[:username] = config[:api_key] if config[:api_key]
      config[:headers]  ||= {}
      config[:request]  ||= {}
      config[:response] ||= {}

      config[:headers][:accept] ||= "application/hal+json"

      # Copy the config into this Configuration instance.
      config.each { |k, v| self[k] = v }

      super()

      configure_user_agent
      configure_cache

      validate
    end

  private

    def configure_user_agent
      frenetic_ua = "Frenetic v#{Frenetic::VERSION}; #{Socket.gethostname}"

      if self[:headers][:user_agent]
        self[:headers][:user_agent] << " (#{frenetic_ua})"
      else
        self[:headers][:user_agent] = frenetic_ua
      end
    end

    def configure_cache
      if self[:cache]
        ignore_headers = self[:cache][:ignore_headers] || []

        self[:cache][:ignore_headers] = (ignore_headers + %w[Set-Cookie X-Content-Digest]).uniq
      end
    end

    def validate
      unless self[:url]
        raise ConfigurationError, "No API URL defined!"
      end
      if self[:cache]
        raise( ConfigurationError, "No cache :metastore defined!" )               if self[:cache][:metastore].to_s == ""
        raise( ConfigurationError, "No cache :entitystore defined!" )             if self[:cache][:entitystore].to_s == ""
        raise( ConfigurationError, "Required cache header filters are missing!" ) if missing_required_headers?
      end
    end

    def missing_required_headers?
      return true if self[:cache][:ignore_headers].empty?

      header_set     = self[:cache][:ignore_headers]
      custom_headers = header_set - %w[Set-Cookie X-Content-Digest]

      header_set == custom_headers
    end

    # TODO: Is this even being used?
    def config_file
      path       = File.join 'config/frenetic.yml'
      config     = YAML.load_file( path )
      env        = ENV['RAILS_ENV'] || ENV['RACK_ENV']

      config[env] || {}
    rescue Errno::ENOENT, NoMethodError
      {}
    end

    def symbolize_keys( arg )
      case arg
      when Array
        arg.map { |elem| symbolize_keys elem }
      when Hash
        Hash[
          arg.map { |key, value|  
            k = key.is_a?(String) ? key.to_sym : key
            v = symbolize_keys value
            [k,v]
          }]
      else
        arg
      end
    end

  end
end