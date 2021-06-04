module Operations
  module Normalizer
    extend ActiveSupport::Concern

    included do
      class_attribute :schema, default: []
      class_attribute :path
      class_attribute :collection, default: false
      attr_reader :data, :query
    end

    class_methods do
      def field(path)
        self.schema += [
          Class.new(::Operations::Normalizer::Field) do
            self.path = path
          end
        ]
      end

      def embed(path, collection: false, &block)
        self.schema += [
          Class.new do
            include ::Operations::Normalizer

            self.path = path
            self.collection = collection
            class_eval(&block) if block_given?
          end
        ]
      end

      def represent(data, **params)
        return new(data, **params).represent unless data.is_a?(Enumerable)

        data.map do |data_element|
          new(data_element, **params).represent
        end
      end
    end

    def initialize(data, query: nil)
      @data = data
      @query = query
    end

    def represent
      return nil if data.nil?

      schema.reduce({}) do |acc, field|
        next acc if query && !query.include?(field.path)

        nested_data = data.public_send(field.path)

        acc.merge(field.path => field.represent(nested_data, query: query.try(field.path)))
      end
    end
  end
end
