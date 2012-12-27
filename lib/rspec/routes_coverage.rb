require 'colored'
require 'rspec/rails'
require 'rspec/routes_coverage/dsl'
require 'rspec/routes_coverage/request_override'

module RSpec
  module RoutesCoverage
    class Railtie < ::Rails::Railtie
      railtie_name :'rspec-routes_coverage'

      rake_tasks do
        load "tasks/rspec/routes_coverage.rake"
      end
    end

    mattr_accessor :pending_routes
    mattr_accessor :excluded_routes
    mattr_accessor :auto_tested_routes
    mattr_accessor :manually_tested_routes
    mattr_accessor :tested_routes_num
    mattr_accessor :routes_num

    def self.auto_remove_pending_route(verb, path)
      recognize_route(verb, path) do |route|
        auto_tested_routes << route unless auto_tested_routes.include?(route)
        pending_routes.delete route
      end
    end

    def self.manually_remove_pending_route(verb, path)
      recognize_route(verb, path) do |route|
        manually_tested_routes << route unless manually_tested_routes.include?(route)
        pending_routes.delete route
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

      self.pending_routes = ::Rails.application.routes.routes.routes.select{|x|
        !x.app.is_a?(Sprockets::Environment)
      }

      self.excluded_routes        = []
      self.auto_tested_routes     = []
      self.manually_tested_routes = []

      # Skip config.exclude_routes
      unless RSpec.configuration.routes_coverage.exclude_routes.blank?
        selector = Regexp.union(*RSpec.configuration.routes_coverage.exclude_routes)
        self.pending_routes.select! do |x|
          keep = ("#{x.verb.to_s[8..-3]} #{x.path.spec}".strip =~ selector).nil?
          self.excluded_routes << x unless keep
          keep
        end
      end

      # Skip config.exclude_namespaces
      selector  = []
      selector += RSpec.configuration.routes_coverage.exclude_namespaces.map do |n|
        "^/#{n}/"
      end
      unless selector.blank?
        selector = /(#{selector.join(')|(')})/
        self.pending_routes.select! do |x| 
          keep = (x.path.spec.to_s =~ selector).nil?
          self.excluded_routes << x unless keep
          keep
        end
      end

      self.routes_num        = ::Rails.application.routes.routes.routes.length
      self.tested_routes_num = self.pending_routes.length
    end
  end
end

RSpec.configure do |config|
  config.add_setting :routes_coverage
  config.routes_coverage = OpenStruct.new

  config.routes_coverage.exclude_namespaces = []
  config.routes_coverage.exclude_routes = []

  config.after(:suite) do
    RSpec::RoutesCoverage.initialize_routes!

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
      legend = { 
        magenta: :excluded_routes,
        green:   :manually_tested_routes,
        blue:    :auto_tested_routes,
        yellow:  :pending_routes 
      }

      legend.each do |color, name|
        total = name == :excluded_routes ? RSpec::RoutesCoverage.routes_num : RSpec::RoutesCoverage.tested_routes_num

        puts "\n\n"
        puts "#{name.to_s.humanize} (#{RSpec::RoutesCoverage.send(name).length}/#{total})".send(color).bold
        puts "\n"
        inspector.format(RSpec::RoutesCoverage.send(name)).each do |route|
          puts '  ' + route.send(color)
        end
      end
    else
      puts  "\n\n"
      puts  'Routes coverage stats:'
      puts  "   Routes to test: #{RSpec::RoutesCoverage.tested_routes_num}/#{RSpec::RoutesCoverage.routes_num}".magenta
      puts  "  Manually tested: #{RSpec::RoutesCoverage.manually_tested_routes.length}/#{RSpec::RoutesCoverage.tested_routes_num}".green
      puts  "      Auto tested: #{RSpec::RoutesCoverage.auto_tested_routes.length}/#{RSpec::RoutesCoverage.tested_routes_num}".blue
      print "          Pending: #{RSpec::RoutesCoverage.pending_routes.length}/#{RSpec::RoutesCoverage.tested_routes_num}".yellow
    end
  end
end