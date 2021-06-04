module Operations
  module Normalizer
    class Collection
      attr_reader :collection

      def initialize(collection)
        @collection = collection
      end

      def represent
        collection.map(&:represent)
      end
    end
  end
end
