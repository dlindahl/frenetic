ENV['RAILS_ENV'] ||= 'test'

require 'awesome_print'
require 'rspec'
require 'frenetic'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir['./spec/support/**/*.rb'].each { |f| require(f) }
