# -*- encoding: utf-8 -*-
require File.expand_path('../lib/frenetic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Derek Lindahl"]
  gem.email         = ["dlindahl@customink.com"]
  gem.description   = %q{An opinionated Ruby-based Hypermedia API client.}
  gem.summary       = %q{Here lies a Ruby-based Hypermedia API client that expects HAL+JSON and makes a lot of assumptions about your API.}
  gem.homepage      = "http://dlindahl.github.com/frenetic/"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "frenetic"
  gem.require_paths = ["lib"]
  gem.version       = Frenetic::VERSION
  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency             'faraday',             '>= 0.8'
  gem.add_dependency             'faraday_middleware',  '>= 0.8'
  gem.add_dependency             'activesupport',       '>= 3'
  gem.add_dependency             'addressable',         '~> 2.3.4'

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'rspec',               '~> 3.0.0'
  gem.add_development_dependency 'rack-cache',          '~> 1.2'
  gem.add_development_dependency 'faraday-http-cache',  '~> 0.4.2'
  gem.add_development_dependency 'webmock',             '~> 1.18.0'
  gem.add_development_dependency 'timecop',             '~> 0.7.1'
  gem.add_development_dependency 'appraisal',           '~> 1.0.2'
end
