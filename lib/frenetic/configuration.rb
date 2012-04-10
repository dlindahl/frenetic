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

      if config[:"content-type"]
        config[:headers][:accepts] = config[:"content-type"]
      else
        config[:headers][:accepts] = "application/hal+json"
      end

      # Copy the config into this Configuration instance.
      config.each { |k, v| self[k] = v }

      super()

      configure_user_agent

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

    def validate
      unless self[:url]
        raise ConfigurationError, "No API URL defined!"
      end
    end

    def config_file
      config_path = File.join( 'config', 'frenetic.yml' )

      if File.exists? config_path
        config = YAML.load_file( config_path )
        env    = ENV['RAILS_ENV'] || ENV['RACK_ENV']

        if config and config.has_key? env
          config[env]
        else
          {}
        end
      else
        {}
      end
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