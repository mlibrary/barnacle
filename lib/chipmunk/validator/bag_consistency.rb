# frozen_string_literal: true

require_relative "validator"

module Chipmunk
  module Validator

    # Validates the internal consistency of a bag, with no external information.
    class BagConsistency < Validator

      METADATA_TAGS = ["Metadata-URL", "Metadata-Type", "Metadata-Tagfile"].freeze

      validates "bag on disk must be valid",
        condition: proc {|bag| bag.valid? },
        error: proc {|bag| "Error validating bag:\n" + indent_array(bag.errors.full_messages) }

      validates "chipmunk-info.txt has metadata tags",
        error: proc { "Some (but not all) metadata tags #{METADATA_TAGS} missing in chipmunk-info.txt" },
        condition: proc {|bag|
          METADATA_TAGS.all? {|tag| bag.chipmunk_info.key?(tag) } ||
            METADATA_TAGS.none? {|tag| bag.chipmunk_info.key?(tag) }
        }

      validates "bag on disk has referenced metadata files",
        only_if: proc {|bag| bag.chipmunk_info["Metadata-Tagfile"] },
        error: proc {|bag| "Missing referenced metadata #{bag.chipmunk_info["Metadata-Tagfile"]}" },
        condition: proc {|bag|
          bag.tag_files.map {|f| File.basename(f) }
            .include?(bag.chipmunk_info["Metadata-Tagfile"])
        }

      private

      def indent_array(array, width = 2)
        array.map {|s| " " * width + s }.join("\n")
      end
    end

  end
end
