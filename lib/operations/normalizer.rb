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
      def field(path, type, null: false)
        self.schema += [
          ::Operations::Normalizer::Field.build_class(path: path, type: type, null: null)
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

      def normalize(data, **params)
        return new(data, **params).normalize unless data.is_a?(Enumerable)

        data.map do |data_element|
          new(data_element, **params).normalize
        end
      end
    end

    def initialize(data, query: nil)
      @data = data
      @query = query
    end

    def normalize
      return nil if data.nil?

      schema.reduce({}) do |acc, field|
        next acc if query && !query.include?(field.path)

        nested_data = data.public_send(field.path)

        acc.merge(field.path => field.normalize(nested_data, query: query.try(field.path)))
      end
    end
  end
end
