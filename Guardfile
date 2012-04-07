# More info at https://github.com/guard/guard#readme

guard 'rspec', :notification => false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})           { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')        { "spec" }
  watch(%r{^spec/support/(.+)\.rb$})  { "spec" }
end

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/environment.rb')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end
