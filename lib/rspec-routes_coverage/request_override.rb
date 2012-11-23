require 'action_dispatch/testing/integration'

module ActionDispatch
  module Integration
    class Session
      private

      alias_method :_old_process_method, :process

      def process(method, path, parameters = nil, rack_env = nil)
        RSpec::RoutesCoverage.auto_remove_pending_route method, path
        _old_process_method method, path, parameters, rack_env
      end
    end
  end
end