# frozen_string_literal: true

RSpec.describe Chipmunk::Validator::StorageFormat do
  let(:storage_format) { "somestorage_format" }
  let(:validator) { described_class.new(storage_format) }

  context "when the storage_format matches" do
    let(:sip) { double(:sip, storage_format: storage_format) }

    it "is valid" do
      expect(validator.valid?(sip)).to be true
    end
  end

  context "when the storage_format diverges" do
    let(:sip) { double(:sip, identifier: "someid", storage_format: "sandwich") }

    it "reports the error" do
      expect(validator.errors(sip))
        .to include("SIP someid has invalid storage_format: sandwich")
    end
  end
end
