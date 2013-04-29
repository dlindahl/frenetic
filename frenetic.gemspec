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

  gem.add_dependency             'faraday',             '~> 0.8.1'
  gem.add_dependency             'faraday_middleware',  '~> 0.9.0'
end
