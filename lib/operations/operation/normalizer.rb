module Operations
  module Operation
    module Normalizer
      extend ActiveSupport::Concern

      included do
        class_attribute :normalizer_class

        def normalize(query: nil)
          normalizer_class.normalize(self[:resource], query: query)
        end

        private

        def normalizer_class
          @normalizer_class ||= self.class.normalizer_class || "#{resource_name}Normalizer".constantize
        end
      end

      class_methods do
        def normalizer_class!(klass)
          self.normalizer_class = klass
        end
      end
    end
  end
end
