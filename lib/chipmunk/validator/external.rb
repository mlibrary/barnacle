# frozen_string_literal: true

require_relative "validator"
require "open3"

module Chipmunk
  module Validator

    # Validate that some external validation passes
    class External < Validator

      # @param command [String] The fully specified command, including any reference
      #   to the object to be validated.
      def initialize(package)
        @package = package
      end

      def command
        if ext_bin
          path = Services.incoming_storage.for(package).path
          [ext_bin, package.identifier, path].join(" ")
        end
      end

      validates "the object passes external validation",
        only_if: proc {|validatable| !command.nil? && validatable.valid? },
        precondition: proc { Open3.capture3(command) },
        condition: proc {|_, _, _, status| status.exitstatus.zero? },
        error: proc {|_, _, stderr, _| "Error validating content\n" + stderr }

      private

      attr_reader :package

      def ext_bin
        @ext_bin ||= Rails.application.config
          .validation["external"][package.content_type.to_s]
      end

    end

  end
end
