require 'rspec/rails'
module RSpec
  module RoutesCoverage
    module Helpers
      def perform_example_request(params=nil, headers=nil)
        path = get_example_request_path
        if params.is_a? Hash
          params.each do |key, val|
            path.gsub(":#{key}", val.to_s) if path.match ":#{key}"
          end
        end
        self.send get_example_request_verb.downcase, path, params, headers
      end

      def get_example_request_path
        self.class.ancestors.reduce('') do |path, klass|
          if klass.respond_to?(:metadata) && klass.metadata.is_a?(RSpec::Core::Metadata) && klass.metadata[:request_path]
            klass.metadata[:request_path] + path
          else
            path
          end
        end
      end

      def get_example_request_verb
        self.class.metadata[:method]
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::RoutesCoverage::Helpers
end