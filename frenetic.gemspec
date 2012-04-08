# -*- encoding: utf-8 -*-
require File.expand_path('../lib/frenetic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Derek Lindahl"]
  gem.email         = ["dlindahl@customink.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "frenetic"
  gem.require_paths = ["lib"]
  gem.version       = Frenetic::VERSION

  gem.add_dependency             'faraday',       '~> 0.7.6'

  gem.add_development_dependency 'guard-spork',   '~> 0.6.0'
  gem.add_development_dependency 'guard-rspec',   '~> 0.7.0'
  gem.add_development_dependency 'rspec',         '~> 2.9.0'
  gem.add_development_dependency 'bourne',        '~> 1.1.2'
  gem.add_development_dependency 'webmock',       '~> 1.8.6'
  gem.add_development_dependency 'vcr',           '~> 2.0.1'
end
