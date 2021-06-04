module Operations
  module Normalizer
    class Field
      attr_reader :data

      class_attribute :path

      def initialize(data, **_params)
        @data = data
      end

      def represent
        data
      end

      def self.represent(*args, **params)
        new(*args, **params).represent
      end
    end
  end
end
