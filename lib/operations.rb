# frozen_string_literal: true

require "active_support/all"
require "dry-validation"

require_relative "operations/version"
require_relative "operations/memoize"
require_relative "operations/validation"
require_relative "operations/operation"

module Operations
  class Error < StandardError; end
  # Your code goes here...
end
