module Operations
  module Validation
    extend ActiveSupport::Concern

    included do
      class_attribute :validation_contract
    end

    class_methods do
      def validate(&block)
        self.validation_contract = Class.new(Dry::Validation::Contract, &block)
      end
    end

    def validation_result
      validation_contract&.new&.call(raw_params)
    end

    def params
      validation_result.to_h
    end

    def errors
      return {} unless self[:validation_result]

      self[:validation_result].errors.to_h
    end

    def raw_params
      raise NotImplementedError
    end
  end
end
