# frozen_string_literal: true

require_relative "validator"

module Chipmunk
  module Validator
    class StorageFormat < Validator
      def initialize(storage_format)
        @storage_format = storage_format
      end

      validates "the storage_format matches",
        condition: proc {|sip| sip.storage_format == storage_format },
        error: proc {|sip|
          "SIP #{sip.identifier} has invalid storage_format: #{sip.storage_format}"
        }

      private

      attr_reader :storage_format
    end
  end
end
