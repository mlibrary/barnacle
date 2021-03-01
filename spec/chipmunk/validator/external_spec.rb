# frozen_string_literal: true

RSpec.describe Chipmunk::Validator::External do
  let(:content_type) { "mycontenttype" }
  let(:package) { double(:package, identifier: SecureRandom.uuid, content_type: content_type) }
  let(:bag) { double(:bag, valid?: true, path: "/incoming/bag") }
  let(:validator) { described_class.new(package) }

  before(:each) do
    allow(Services.incoming_storage).to receive(:for).and_return(bag)
  end

  context "when there is no external command configured" do
    around(:each) do |example|
      old_ext_validation = Rails.application.config.validation["external"]
      Rails.application.config.validation["external"] = {}
      example.run
      Rails.application.config.validation["external"] = old_ext_validation
    end

    it "is valid" do
      expect(validator.valid?(bag)).to be true
    end
  end

  context "when the external command succeeds" do
    around(:each) do |example|
      old_ext_validation = Rails.application.config.validation["external"]
      Rails.application.config.validation["external"] = { content_type => "/bin/true" }
      example.run
      Rails.application.config.validation["external"] = old_ext_validation
    end

    it "constructs the command with the configured executable" do
      expect(validator.command).to match(/^\/bin\/true/)
    end

    it "includes the path to the source archive" do
      expect(validator.command).to match("/incoming/bag")
    end

    it "is valid" do
      expect(validator.valid?(bag)).to be true
    end
  end

  context "when the external command fails" do
    around(:each) do |example|
      old_ext_validation = Rails.application.config.validation["external"]
      Rails.application.config.validation["external"] = { content_type => "ls /nondir" }
      example.run
      Rails.application.config.validation["external"] = old_ext_validation
    end

    it { expect(validator.valid?(bag)).to be false }

    it "reports the error" do
      expect(validator.errors(bag)).to include(a_string_matching(/cannot access/))
    end

    it "skips this validator if the bag is invalid" do
      bag = double(:invalid_bag, valid?: false)
      expect(validator.valid?(bag)).to be true
    end
  end
end
