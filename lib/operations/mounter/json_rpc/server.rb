# Detect all the data required to describe API endpoint from Operation class

module Operations
  module Mounter
    module JsonRpc
      class Server
        JSON_RPC_VERSION = 2.0

        attr_reader :content, :operations_map, :rpc_response

        def initialize(content, operations_map)
          @content = content
          @operations_map = operations_map
          @rpc_response = Response.new
        end

        def call
          return rpc_response.parse_error unless request

          return rpc_response.invalid_request unless validate_request

          rpc_response.request_id = request["id"]

          process
        rescue StandardError => e
          # TODO use log level
          rpc_response.internal_error(e.full_message)
        end

        private

        def validate_request
          true
        end

        def request
          @request ||= MultiJson.decode(content)
        rescue StandardError
          nil
        end

        def process
          operation_class = operations_map[request["method"]]

          return rpc_response.method_not_found unless operation_class

          operation = operation_class.new(**sanitized_args).call

          return rpc_response.result(operation.normalize) if operation.success?

          rpc_response.operation_validation_error(operation[:errors])
        end

        def sanitized_args
          @sanitized_args ||= case request["params"]
          when Hash
            request["params"].symbolize_keys
          when nil
            {}
          else
            raise ArgumentError
          end
        end
      end
    end
  end
end
