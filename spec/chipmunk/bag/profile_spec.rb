# frozen_string_literal: true

require "chipmunk/bag/profile"

RSpec.describe Chipmunk::Bag::Profile do
  let(:bagger_profile) do
    described_class.new("file://" +  (application_root/"spec"/"support"/"fixtures"/"test-profile.json").to_s)
  end

  let(:errors) { [] }

  it "parses a profile" do
    expect(bagger_profile).not_to be(nil)
  end

  context "with bag info appropriate for the profile" do
    let(:bag_info) { { "Foo" => "bar", "Baz" => "quux" } }

    it "is true" do
      expect(bagger_profile.valid?(bag_info)).to be true
    end

    it "reports no errors" do
      bagger_profile.valid?(bag_info, errors: errors)
      expect(errors).to be_empty
    end
  end

  context "with bag info missing a required tag" do
    let(:bag_info) { { "Baz" => "quux" } }

    it "is false" do
      expect(bagger_profile.valid?(bag_info)).to be false
    end

    it "reports an error" do
      bagger_profile.valid?(bag_info, errors: errors)
      expect(errors).to include a_string_matching(/Foo.*required/)
    end
  end

  context "with a tag with a disallowed value" do
    let(:bag_info) { { "Foo" => "bar", "Baz" => "disallowed" } }

    it "is false" do
      expect(bagger_profile.valid?(bag_info)).to be false
    end

    it "reports an error" do
      bagger_profile.valid?(bag_info, errors: errors)
      expect(errors).to include a_string_matching(/allowed/)
    end
  end

  context "when an optional tag is missing" do
    let(:bag_info) { { "Foo" => "bar" } }

    it "is true" do
      expect(bagger_profile.valid?(bag_info)).to be true
    end

    it "reports no errors" do
      bagger_profile.valid?(bag_info, errors: errors)
      expect(errors).to be_empty
    end
  end
end
