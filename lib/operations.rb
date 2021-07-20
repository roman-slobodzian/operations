# frozen_string_literal: true

require "active_support/all"
require "dry-validation"
require "multi_json"

module Operations
  class Error < StandardError; end

  module Normalizer; end

  # Your code goes here...
end

require_relative "operations/version"
require_relative "operations/memoize"
require_relative "operations/mounter/json_rpc/response"
require_relative "operations/mounter/json_rpc/server"
require_relative "operations/mounter/json_rpc/middleware"
require_relative "operations/normalizer/field"
require_relative "operations/normalizer"
require_relative "operations/operation/normalizer"
require_relative "operations/operation/auto_registration"
require_relative "operations/validation"
require_relative "operations/operation"
