# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rspec-routes_coverage/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Shaydurov"]
  gem.email         = ["a.shaydurov@roundlake.ru"]
  gem.description   = %q{This gem allows to specify and track the coverage of tested API requests according to app's routes.}
  gem.summary       = %q{This gem allows to specify and track the coverage of tested API requests according to app's routes.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rspec-routes_coverage"
  gem.require_paths = ["lib"]
  gem.version       = RSpec::RoutesCoverage::VERSION

  gem.add_dependency 'rspec-rails'
  gem.add_dependency 'colored'
  gem.add_dependency 'actionpack'
end
