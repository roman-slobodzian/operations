module Operations
  class Operation
    include Memoize
    include Validation
    include Operation::Normalizer

    attr_accessor :params, :user_token

    def initialize(params: nil, user_token: nil)
      self.params = params
      self.user_token = user_token
    end

    def call
      return self if failure?

      self[:result] = execute

      self
    end

    def failure?
      !success?
    end

    def success?
      self[:errors].empty?
    end

    def result
      nil
    end

    private

    # Business logic code should be implemented in this method
    def execute
      raise NotImplementedError, %(Please implement "execute" method in #{self.class.name} operation class)
    end
  end
end
