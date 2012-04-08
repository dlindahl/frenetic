class Frenetic
  class Configuration < Hash

    def initialize( custom_config = {} )
      config = config_file.merge custom_config

      self[:url]     = config['url']     if config['url']
      self[:user]    = config['api_key'] if config['api_key']
      # TODO: Make the Accepts header configurable or default to JSON
      self[:accepts] = "application/vnd.customink-inkers-#{config['version']}+json" if config['version']
      
      super()
    end
  
  private

    def config_file
      config_path = File.join( 'config', 'frenetic.yml' )

      if File.exists? config_path
        YAML.load_file( config_path )[ENV['RAILS_ENV']] || {}
      else
        {}
      end
    end

  end
end