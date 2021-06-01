module Operations
  module Memoize
    extend ActiveSupport::Concern

    def memoized
      @memoized ||= {}
    end

    def [](key)
      if memoized.key?(key)
        memoized[key]
      elsif respond_to?(key, true)
        memoized[key] = send(key)
      else
        throw "Unexpected memoized property: #{key} on #{self.class.name}"
      end
    end

    def []=(key, val)
      memoized[key] = val
    end
  end
end
