module Operations
  class Operation
    module Normalizer
      extend ActiveSupport::Concern

      included do
        class_attribute :_normalizer
        class_attribute :_collection, default: false

        def normalize(query: nil)
          return unless self.class.defined_normalizer

          self.class.defined_normalizer.normalize(self[:result], query: query)
        end
      end

      class_methods do
        def normalizer(normalizer = nil, collection: false, &block)
          self._collection = true if collection

          if normalizer.is_a?(Symbol)
            # When type is a scalar
            return self._normalizer = Class.new do
              include Operations::Normalizer

              self.type = normalizer
            end
          elsif !normalizer.nil?
            # When type is a Normalizer class
            return self._normalizer = normalizer
          end

          # When field types are passed as a block
          # TODO, setup default Normalizer module or base class
          self._normalizer = Class.new do
            include Operations::Normalizer

            instance_eval(&block)
          end
        end

        def collection
          self._collection = true
        end

        def collection?
          _collection
        end

        def defined_normalizer
          return @defined_normalizer if defined?(@defined_normalizer)

          return @defined_normalizer = _normalizer unless _normalizer.nil?

          @defined_normalizer = resource_class && "#{resource_class.name}Normalizer".safe_constantize
        end

        def resource_class
          name.match(/(Operations::)?(\w+)::(.+)$/)[2]&.singularize&.safe_constantize
        end
      end
    end
  end
end
