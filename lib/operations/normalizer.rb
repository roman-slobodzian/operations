module Operations
  module Normalizer
    extend ActiveSupport::Concern

    TYPES = %i[number string boolean].freeze

    included do
      class_attribute :schema, default: []
      class_attribute :collection, default: false
      class_attribute :null, default: false
      class_attribute :type, default: :hash
      class_attribute :path
      attr_reader :data, :query
    end

    class_methods do
      def field(path, type, collection: false, null: false, &block)
        self.schema += [
          Class.new do
            include ::Operations::Normalizer

            self.path = path
            self.type = type
            self.null = null
            self.collection = collection
            class_eval(&block) if block_given?
          end
        ]
      end

      def embed(path, collection: false, null: false, &block)
        field(path, :hash, collection: collection, null: null, &block)
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

      return normalize_schema if type == :hash

      normalize_scalar
    end

    def normalize_scalar
      # TODO: validate datatype and log
      data
    end

    def normalize_schema
      schema.reduce({}) do |acc, field|
        next acc if query && !query.include?(field.path)

        nested_data = data.public_send(field.path)

        acc.merge(field.path => field.normalize(nested_data, query: query.try(field.path)))
      end
    end
  end
end
