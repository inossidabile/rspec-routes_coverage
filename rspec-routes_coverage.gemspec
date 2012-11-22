# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rspec-routes_coverage/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Shaydurov"]
  gem.email         = ["a.shaydurov@roundlake.ru"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rspec-routes_coverage"
  gem.require_paths = ["lib"]
  gem.version       = RSpec::RoutesCoverage::VERSION

  gem.add_dependency 'rspec-rails'
  gem.add_dependency 'actionpack'
end
