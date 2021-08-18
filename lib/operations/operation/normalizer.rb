module Operations
  class Operation
    module Normalizer
      extend ActiveSupport::Concern

      included do
        class_attribute :_normalizer

        def normalize(query: nil)
          defined_normalizer.normalize(self[:resource], query: query)
        end
      end

      class_methods do
        def normalizer(klass = nil, &block)
          return self._normalizer = klass unless klass.nil?

          # TODO, setup default Normalizer module or base class
          self._normalizer = Class.new do
            include Operations::Normalizer

            instance_eval(&block)
          end
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
