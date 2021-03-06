# Detect all the data required to describe API endpoint from Operation class

module Operations
  module Mounter
    module JsonRpc
      class Middleware
        APPLICATION_JSON = "application/json".freeze
        APPLICATION_JSON_HEADER = {"Content-Type" => "application/json"}.freeze

        attr_reader :app, :operation_classes, :mount_path

        def initialize(app, operation_classes:, path: "/")
          @app = app
          @mount_path = path
          @operation_classes = operation_classes

          setup_code_reloader
        end

        def call(env)
          req = Rack::Request.new(env)

          return app.call(env) unless req.path == mount_path

          resp = Rack::Response.new

          server = Server.new(req.body.read, operation_classes_map)

          resp.write(MultiJson.encode(server.call))
          resp.finish
        end

        def self.operation_name(operation_class)
          operation_class.name.match(/(Operations::)?(.+)$/)[2].underscore
        end

        private

        def operation_classes_map
          @operation_classes_map ||= operation_classes.map { |o| [self.class.operation_name(o), o] }.to_h
        end

        def setup_code_reloader
          return unless defined?(::Rails::Autoloaders)

          operation_classes.each do |operation_class|
            ::Rails::Autoloaders.main.on_load(operation_class.name) do
              @operation_classes_map = nil
              @operation_classes = operation_classes.map { |o| o.name.constantize }
            end
          end
        end
      end
    end
  end
end
