# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rspec/routes_coverage/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Shaydurov", "Boris Staal"]
  gem.email         = ["a.shaydurov@roundlake.ru", "boris@roundlake.ru"]
  gem.description   = %q{Rails-RSpec plugin that will track the coverage of routes among your request specs}
  gem.summary       = %q{Rails-RSpec plugin that will track the coverage of routes among your request specs}
  gem.homepage      = "https://github.com/inossidabile/rspec-routes_coverage"

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
