module Operations
  module Normalizer
    class Field
      TYPES = %i[number string boolean].freeze

      attr_reader :data

      class_attribute :path, :type, :null

      def initialize(data, **_params)
        @data = data
      end

      def represent
        # TODO: validate datatype and log
        data
      end

      def self.represent(*args, **params)
        new(*args, **params).represent
      end

      def self.build_class(path:, type:, null:)
        raise "Invalid type #{type.type}, please use one of #{TYPES.join(", ")}" unless TYPES.include?(type)

        Class.new(::Operations::Normalizer::Field) do
          self.path = path
          self.type = type
          self.null = null
        end
      end
    end
  end
end
