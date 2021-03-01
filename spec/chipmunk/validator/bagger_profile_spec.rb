# frozen_string_literal: true

RSpec.describe Chipmunk::Validator::BaggerProfile do
  let(:validator) { described_class.new(package) }
  let(:bag) { double(:bag, bag_info: { "Baz" => "quux" }) }
  let(:package) { double(:package, content_type: "audio") }

  around(:each) do |example|
    old_profile = Rails.application.config.validation["bagger_profile"]["audio"]
    test_profile = "file://" + fixture("test-profile.json")
    Rails.application.config.validation["bagger_profile"]["audio"] = test_profile.to_s
    example.run
    Rails.application.config.validation["bagger_profile"]["audio"] = old_profile
  end

  it "tests the bag against the profile" do
    expect(validator.errors(bag)).to include(a_string_matching(/Foo.*required/))
  end
end
