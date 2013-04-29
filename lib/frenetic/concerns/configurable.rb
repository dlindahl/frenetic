require 'active_support/configurable'
require 'active_support/concern'

require 'frenetic/configuration'

class Frenetic
  module Configurable
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Configurable
      # Don't allow the class to be configured
      class << self
        undef :configure
      end
    end

    def initialize( cfg = {} )
      config.merge! Frenetic::Configuration.new(cfg).attributes

      @builder_config = Proc.new if block_given?
    end

    def configure
      yield config
    end

  private

    def validate_configuration!
      raise( ConfigError, 'A URL must be defined' ) unless config.url
    end

  end
end