require 'spork'
ENV['RAILS_ENV'] ||= 'test'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  require 'rspec'
end

Spork.each_run do
  # This code will be run each time you run your specs.
  require 'inker_directory_client'
end