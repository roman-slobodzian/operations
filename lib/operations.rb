# frozen_string_literal: true

require "active_support/all"
require "dry-validation"

module Operations
  class Error < StandardError; end

  module Normalizer; end

  # Your code goes here...
end

require_relative "operations/version"
require_relative "operations/memoize"
require_relative "operations/normalizer/collection"
require_relative "operations/normalizer/field"
require_relative "operations/normalizer"
require_relative "operations/validation"
require_relative "operations/operation"
