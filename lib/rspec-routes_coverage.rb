require 'colored'
require 'rspec/rails'
require 'rspec-routes_coverage/dsl'
require 'rspec-routes_coverage/request_override'

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
      initialize_routes!

      env = Rack::MockRequest.env_for path, method: verb.upcase
      req = ::Rails.application.routes.request_class.new env
      ::Rails.application.routes.router.recognize(req) do |route|
        yield route
      end
    end

    def self.initialize_routes!
      return if self.pending_routes

      ::Rails.application.reload_routes!
      self.pending_routes         = ::Rails.application.routes.routes.routes.clone
      self.routes_num             = self.pending_routes.length
      self.auto_tested_routes     = []
      self.manually_tested_routes = []
    end
  end
end

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

    if ENV['LIST_ROUTES_COVERAGE']
      { green: :manually_tested_routes, blue: :auto_tested_routes, yellow: :pending_routes }.each do |color, name|
        puts "\n\n"
        puts "#{name.to_s.humanize} (#{RSpec::RoutesCoverage.send(name).length}/#{RSpec::RoutesCoverage.routes_num})".send(color).bold
        puts "\n"
        inspector.format(RSpec::RoutesCoverage.send(name)).each do |route|
          puts '  ' + route.send(color)
        end
      end
    else
      puts  "\n\n"
      puts  'Routes coverage stats:'
      puts  "  Manually tested: #{RSpec::RoutesCoverage.manually_tested_routes.length}/#{RSpec::RoutesCoverage.routes_num}".green
      puts  "      Auto tested: #{RSpec::RoutesCoverage.auto_tested_routes.length}/#{RSpec::RoutesCoverage.routes_num}".blue
      print "          Pending: #{RSpec::RoutesCoverage.pending_routes.length}/#{RSpec::RoutesCoverage.routes_num}".yellow
    end
  end
end