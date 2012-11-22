module RSpec
  module RoutesCoverage
    module DSL
      def describe_request(*args, &block)
        unless args.last.is_a?(Hash) && args.last[:method] && args.last[:request_path]
          verb, path = args[0].split ' '
          opts = { method: verb, request_path: path }
          if args.last.is_a? Hash
            args.last.merge! opts
          else
            args << opts
          end
        end

        describe *args do
          before :all do
            RSpec::RoutesCoverage.remove_pending_route get_example_request_verb, get_example_request_path
          end if RSpec::RoutesCoverage.pending_routes?

          instance_eval(&block) if block
        end
      end
    end
  end
end

extend RSpec::RoutesCoverage::DSL
Module.send(:include, RSpec::RoutesCoverage::DSL)