# frozen_string_literal: true

RSpec.describe Chipmunk::Validator::BagConsistency do
  let(:validator) { described_class.new }
  let(:tag_files) { [fixture("marc.xml")] }
  let(:validity) { true }
  let(:bag_errors) { double(:empty_bag_errors) }
  let(:bag) do
    double(
      :bag,
      valid?: validity,
      errors: bag_errors,
      tag_files: tag_files,
      chipmunk_info: chipmunk_info
    )
  end
  let(:chipmunk_info) do
    {
      "Metadata-Type"    => "MARC",
      "Metadata-URL"     => "http://what.ever",
      "Metadata-Tagfile" => "marc.xml"
    }
  end

  context "when bag#valid? is false" do
    let(:validity) { false }
    let(:bag_errors) { double("bag_errors", full_messages: ["injected error"]) }

    it "is invalid" do
      expect(validator.valid?(bag)).to be false
    end

    it "reports the errors from the bag" do
      expect(validator.errors(bag)).to include(
        a_string_matching(/Error validating.*\n  injected error$/)
      )
    end
  end

  context "when the bag does not include the referenced metadata file" do
    let(:tag_files) { [] }

    it "reports missing tag files" do
      expect(validator.errors(bag))
        .to include(a_string_matching(/Missing.*marc.xml/))
    end
  end

  context "when the bag does not any include descriptive metadata tags" do
    let(:tag_files) { [] }
    let(:chipmunk_info) { {} }

    it "is valid" do
      expect(validator.valid?(bag)).to be true
    end
  end

  context "when the bag has only some descriptive metadata tags" do
    let(:chipmunk_info) do
      {
        "Metadata-URL"     => "http://what.ever",
        "Metadata-Tagfile" => "marc.xml"
      }
    end

    it "reports missing metadata tag" do
      expect(validator.errors(bag))
        .to include(a_string_matching(/Metadata-Type/))
    end
  end
end
