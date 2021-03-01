# frozen_string_literal: true

require "securerandom"

RSpec.describe Chipmunk::Validator::BagMatchesPackage do
  let(:validator) { described_class.new(package) }
  let(:bag) { double(:bag, chipmunk_info: chipmunk_info) }
  let(:package) do
    double(
      :package,
      bag_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      content_type: "audio"
    )
  end
  let(:good_chipmunk_info) do
    {
      "External-Identifier"   => package.external_id,
      "Chipmunk-Content-Type" => package.content_type,
      "Bag-ID"                => package.bag_id
    }
  end

  context "when everything matches" do
    let(:chipmunk_info) { good_chipmunk_info }

    it { expect(validator.valid?(bag)).to be true }
  end

  context "when its external ID does not match" do
    let(:chipmunk_info) { good_chipmunk_info.merge("External-Identifier" => "something-different") }

    it "reports the error" do
      expect(validator.errors(bag))
        .to contain_exactly(a_string_matching(/External-Identifier/))
    end
  end

  context "when its bag ID does not match the queue item" do
    let(:chipmunk_info) { good_chipmunk_info.merge("Bag-ID" => "something-different") }

    it "reports the error" do
      expect(validator.errors(bag))
        .to contain_exactly(a_string_matching(/Bag-ID/))
    end
  end

  context "when its package type does not match the queue item" do
    let(:chipmunk_info) { good_chipmunk_info.merge("Chipmunk-Content-Type" => "something-different") }

    it "reports the error" do
      expect(validator.errors(bag))
        .to contain_exactly(a_string_matching(/Chipmunk-Content-Type/))
    end
  end
end
