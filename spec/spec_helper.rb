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
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
    config.treat_symbols_as_metadata_keys_with_true_values = true
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