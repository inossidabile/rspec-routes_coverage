require 'rspec/rails'
require 'rspec-routes_coverage/dsl'

module RSpec
  module RoutesCoverage
    class Railtie < ::Rails::Railtie
      railtie_name :'rspec-routes_coverage'

      rake_tasks do
        load "tasks/rspec-routes_coverage.rake"
      end
    end

    mattr_accessor :pending_routes
    mattr_accessor :auto_tested_routes
    mattr_accessor :manually_tested_routes
    mattr_accessor :routes_num

    def self.auto_remove_pending_route(verb, path)
      recognize_route(verb, path) do |route|
        unless manually_tested_routes.include? route
          pending_routes.delete route
          auto_tested_routes << route unless auto_tested_routes.include?(route)
        end
      end
    end

    def self.manually_remove_pending_route(verb, path)
      recognize_route(verb, path) do |route|
        manually_tested_routes << route unless manually_tested_routes.include?(route)
        pending_routes.delete route
        auto_tested_routes.delete route
      end
    end

    def self.recognize_route(verb, path)
      if RSpec::RoutesCoverage.pending_routes?
        env = Rack::MockRequest.env_for path, method: verb.upcase
        req = ::Rails.application.routes.request_class.new env
        ::Rails.application.routes.router.recognize(req) do |route|
          yield route
        end
      end
    end

    def self.pending_routes?
      initialize_routes! if ENV['WITH_ROUTES_COVERAGE'] && !self.pending_routes
      !!ENV['WITH_ROUTES_COVERAGE']
    end

    def self.initialize_routes!
      ::Rails.application.reload_routes!
      self.pending_routes         = ::Rails.application.routes.routes.routes.clone
      self.routes_num             = self.pending_routes.length
      self.auto_tested_routes     = []
      self.manually_tested_routes = []
    end
  end
end

if ENV['WITH_ROUTES_COVERAGE']
  require 'rspec-routes_coverage/request_override'
  require 'colored'

  RSpec.configure do |config|
    config.after(:suite) do
      inspector = begin
        require 'rails/application/route_inspector'
        Rails::Application::RouteInspector
      rescue
        require 'action_dispatch/routing/inspector'
        ActionDispatch::Routing::RoutesInspector
      end.new

      inspector.instance_eval do
        def formatted_routes(routes)
          verb_width = routes.map{ |r| r[:verb].length }.max
          path_width = routes.map{ |r| r[:path].length }.max

          routes.map do |r|
            "#{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs]}"
          end
        end
      end

      puts "\n\n"
      puts '-------------------'.yellow
      puts "PENDING ROUTES (#{RSpec::RoutesCoverage.pending_routes.length} OF #{RSpec::RoutesCoverage.routes_num})".yellow
      puts '-------------------'.yellow
      puts "\n\n"
      inspector.format(RSpec::RoutesCoverage.pending_routes).each do |route|
        puts route
      end

      puts "\n\n"
      puts '-------------------'.blue
      puts "TESTED ROUTES (AUTOMATICALLY MARKED, #{RSpec::RoutesCoverage.auto_tested_routes.length} OF #{RSpec::RoutesCoverage.routes_num})".blue
      puts '-------------------'.blue
      puts "\n\n"
      inspector.format(RSpec::RoutesCoverage.auto_tested_routes).each do |route|
        puts route
      end

      puts "\n\n"
      puts '-------------------'.green
      puts "TESTED ROUTES (MANUALLY MARKED, #{RSpec::RoutesCoverage.manually_tested_routes.length} OF #{RSpec::RoutesCoverage.routes_num})".green
      puts '-------------------'.green
      puts "\n\n"
      inspector.format(RSpec::RoutesCoverage.manually_tested_routes).each do |route|
        puts route
      end
    end
  end
end