module Operations
  module Mounter
    module JsonRpc
      class Response
        PARSE_ERROR_CODE = -32_700
        INVALID_REQUEST_CODE = -32_600
        METHOD_NOT_FOUND_CODE = -32_601
        INVALID_PARAMS_CODE = -32_602
        INTERNAL_ERROR_CODE = -32_603

        OPERATION_VALIDATION_ERROR = 422

        attr_accessor :request_id

        def initialize
          @response = {
            jsonrpc: Server::JSON_RPC_VERSION
          }
        end

        def result(result)
          response.merge(
            result: result,
            id: request_id
          )
        end

        def error(code, message, data = nil)
          response.merge(
            error: {
              code: code,
              message: message,
              data: data
            },
            id: request_id
          )
        end

        def parse_error
          error(PARSE_ERROR_CODE, "Parse error")
        end

        def invalid_request
          error(INVALID_REQUEST_CODE, "Invalid Request")
        end

        def method_not_found
          error(METHOD_NOT_FOUND_CODE, "Method not found")
        end

        def invalid_params
          error(INVALID_PARAMS_CODE, "Invalid method parameter(s)")
        end

        def internal_error(details = nil)
          error(INTERNAL_ERROR_CODE, "Internal error", details)
        end

        def operation_validation_error(errors = {})
          error(OPERATION_VALIDATION_ERROR, "Validation failure", errors)
        end

        private

        attr_reader :response
      end
    end
  end
end
