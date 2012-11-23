module RSpec
  module RoutesCoverage
    module DSL
      def describe_request(*args, &block)
        verb, path = if args.last.is_a?(Hash) && args.last[:method] && args.last[:request_path]
          [args.last[:method], args.last[:request_path]]
        else
          args[args[1].is_a?(String) ? 1 : 0].split ' '
        end

        describe *args do
          before :all do
            RSpec::RoutesCoverage.remove_pending_route verb, path
          end if RSpec::RoutesCoverage.pending_routes?

          instance_eval(&block) if block
        end
      end
    end
  end
end

extend RSpec::RoutesCoverage::DSL
Module.send(:include, RSpec::RoutesCoverage::DSL)