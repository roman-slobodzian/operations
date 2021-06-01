module Operations
  module Operation
    extend ActiveSupport::Concern

    included do
      include Memoize
      include Validation

      attr_accessor :params
    end

    def initialize(params)
      self.params = params
    end

    def call
      return if failure?

      execute
    end

    def execute
      raise NotImplementedError(%(Please implement "execute" method in #{self.class.name} operation class))
    end

    def failure?
      !success?
    end

    def success?
      self[:validation_result].success?
    end
  end
end
