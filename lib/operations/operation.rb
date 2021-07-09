module Operations
  module Operation
    extend ActiveSupport::Concern

    included do
      include Memoize
      include Validation
      include Operation::Normalizer

      attr_accessor :params, :user_token
    end

    def initialize(params: nil, user_token: nil)
      self.params = params
      self.user_token = user_token
    end

    def call
      return self if failure?

      execute

      self
    end

    # Business logic code should be implemented in this method
    def execute
      raise NotImplementedError(%(Please implement "execute" method in #{self.class.name} operation class))
    end

    # Is used for business logic and normalizer
    def resource
      raise NotImplementedError(%(Please implement "resource" method in #{self.class.name} operation class))
    end

    def failure?
      !success?
    end

    def success?
      self[:errors].empty?
    end
  end
end
