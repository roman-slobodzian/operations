# Detect all the data required to describe API endpoint from Operation class

module Operations
  module Mounter
    class EndpointMetadata
      attr_reader :operation_class

      def initialize(operation_class)
        self.operation_class = operation_class
      end
    end
  end
end
