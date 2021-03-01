# frozen_string_literal: true

require_relative "validator"

module Chipmunk
  module Validator

    # Validate that the bag is indeed the one specified by the Package
    class BagMatchesPackage < Validator

      # @param package [Package]
      def initialize(package)
        @package = package
      end

      {
        "External-Identifier"   => :external_id,
        "Bag-ID"                => :bag_id,
        "Chipmunk-Content-Type" => :content_type
      }.each_pair do |file_key, db_key|
        validates "#{file_key} in bag on disk matches bag in database",
          condition: proc {|bag| bag.chipmunk_info[file_key] == package.public_send(db_key) },
          error: proc { "uploaded #{file_key} does not match expected value #{package.public_send(db_key)}" }
      end

      private

      attr_reader :package

    end
  end
end
