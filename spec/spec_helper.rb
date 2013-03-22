ENV['RAILS_ENV'] ||= 'test'

require 'rspec'
require 'awesome_print'
require 'vcr'
require 'patron'
require 'frenetic'

RSpec.configure do |config|
  config.filter_run focus:true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end
