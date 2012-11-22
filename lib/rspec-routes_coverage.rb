require 'rspec/rails'
require 'rspec-routes_coverage/dsl'
require 'rspec-routes_coverage/helpers'

module RSpec
  module RoutesCoverage
    class Railtie < ::Rails::Railtie
      railtie_name :'rspec-routes_coverage'

      rake_tasks do
        load "tasks/rspec-routes_coverage.rake"
      end
    end

    mattr_accessor :pending_routes

    def self.remove_pending_route(verb, path)
      env = Rack::MockRequest.env_for path, method: verb.upcase
      req = ::Rails.application.routes.request_class.new env
      ::Rails.application.routes.router.recognize(req) do |route|
        self.pending_routes.delete route
      end
    end

    def self.pending_routes?
      initialize_routes! if ENV['WITH_ROUTES_COVERAGE'] && !@initialized
      self.pending_routes.length > 0
    end

    def self.initialize_routes!
      ::Rails.application.reload_routes!
      self.pending_routes = ::Rails.application.routes.routes.routes.clone
      @initialized = true
    end
  end
end

if ENV['WITH_ROUTES_COVERAGE']
  RSpec.configure do |config|
    config.after(:suite) do
      inspector = begin
        require 'rails/application/route_inspector'
        Rails::Application::RouteInspector
      rescue
        require 'action_dispatch/routing/inspector'
        ActionDispatch::Routing::RoutesInspector
      end

      puts "\nPENDING ROUTES:\n"
      inspector.new.format(RSpec::RoutesCoverage.pending_routes).each do |route|
        puts route
      end
      puts "COVERED #{Rails.application.routes.routes.routes.length - RSpec::RoutesCoverage.pending_routes.length} OF #{Rails.application.routes.routes.routes.length} ROUTES"
    end
  end
end