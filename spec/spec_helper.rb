require 'spork'
ENV['RAILS_ENV'] ||= 'test'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  require 'rspec'
  require 'fakefs/spec_helpers'
  require 'awesome_print'
  require 'bourne'
  require 'vcr'

  RSpec.configure do |config|
    config.mock_with :mocha
  end

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    c.hook_into :webmock
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  require 'frenetic'
end