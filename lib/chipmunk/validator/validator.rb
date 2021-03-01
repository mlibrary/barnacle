# frozen_string_literal: true

module Chipmunk
  module Validator

    # A validator runs compile-time validations against a validatable object
    # passed to #valid? or #errors during run-time. Validations are created
    # with the DSL defined in this class via the ::validates method. Subclasses
    # should define their own initializers and instance variables to facilitate
    # run-time configuration of the validations. The validations themselves
    # are run in instance context via instance_exec.
    #
    # This replaces Chipmunk::Validatable
    class Validator
      class << self
        def validations
          @validations ||= []
        end

        # Define a validation that instances of this validator will run
        # @param _desc [String] A description of the check being performed. This
        #   string is discarded; it is for documentation purposes only.
        # @param only_if [Proc] The condition will only be checked if
        #   this block evaluates to true, which it does by default. The object
        #   being validated is passed to this block.
        # @param precondition [Proc] This will be evaluated prior to the condition
        #   and the error, and its result will be passed in expanded form to
        #   those procs.
        # @param condition [Proc] The primary condition of this validation.
        #   The object being validated is passed to this block.
        # @param error [Proc] A block to build out the error message; it must
        #   return a string. The object being validated is passed to this block.
        def validates(_desc = "", only_if: proc { true }, precondition: proc {}, condition:, error:)
          validations << lambda do |validatable|
            return unless instance_exec(validatable, &only_if)

            precond_result = instance_exec(validatable, &precondition)
            unless instance_exec(validatable, *precond_result, &condition)
              instance_exec(validatable, *precond_result, &error)
            end
          end
        end
      end

      # Whether or not the validatable is valid.
      # @param validatable [Object] An object that can be validated by this validator.
      # @return [Boolean]
      def valid?(validatable)
        errors(validatable).empty?
      end

      # An array of errors from the validation process. An empty array indicates
      # a valid object.
      # @param validatable [Object] An object that can be validated by this validator.
      # @return [Array<String>] An unordered list of errors.
      def errors(validatable)
        validated[validatable] ||= generate_errors(validatable)
      end

      private

      # Actually run the validations, returning an array of errors. nil return
      # values from the validations are removed.
      def generate_errors(validatable)
        self.class.validations.reduce([]) do |errs, validation|
          errs << instance_exec(validatable, &validation)
        end.compact
      end

      # A cache of objects that have already been validated by this validator
      # and their errors.
      def validated
        @validated = {}
      end

    end
  end

end
