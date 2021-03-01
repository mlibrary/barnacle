# frozen_string_literal: true

module Chipmunk

  # The result of a validation attempt
  class ValidationResult

    def initialize(errors)
      @errors = [errors].flatten.compact
      @errors.freeze
    end

    # @return [Array<String>]
    attr_reader :errors

    # @return [Boolean]
    def valid?
      errors.empty?
    end
  end

end
