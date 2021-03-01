# frozen_string_literal: true

require_relative "validator"

module Chipmunk
  module Validator

    # Validate that the bag obeys the spec set by the profile
    class BaggerProfile < Validator

      # @param [Package]
      def initialize(package)
        @package = package
      end

      validates "bag on disk meets bagger profile",
        only_if: proc { uri },
        precondition: proc {|bag|
          [].tap {|errors| profile.valid?(bag.bag_info, errors: errors) }
        },
        condition: proc {|_bag, errors| errors.empty? },
        error: proc {|_bag, errors| errors }

      private

      attr_reader :package

      def uri
        @uri ||= Rails.application.config
          .validation["bagger_profile"][package.content_type.to_s]
      end

      def profile
        if uri
          Bag::Profile.new(uri)
        end
      end
    end

  end
end
