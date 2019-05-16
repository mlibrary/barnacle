# frozen_string_literal: true

require "chipmunk/status"

module Chipmunk
  RSpec.describe Status do
    describe "::success" do
      it "returns a successful status" do
        expect(described_class.success).to eql(described_class.new(true))
      end
      it "accepts a parameter" do
        expect(described_class.success("foo")).to eql(described_class.new(true, "foo"))
      end
    end

    describe "::failure" do
      it "returns a failed status" do
        expect(described_class.failure).to eql(described_class.new(false))
      end
      it "accepts a parameter" do
        expect(described_class.failure(["foo"])).to eql(described_class.new(false, "", ["foo"]))
      end
    end

    describe "#output" do
      let(:output) { "foomp" }
      let(:status) { described_class.new(true, output) }

      it "returns the output" do
        expect(status.output).to eql(output)
      end
    end

    describe "#errors" do
      let(:errors) { ["some_error"] }
      let(:failure) { described_class.new(false, "", errors) }

      it "returns the errors" do
        expect(failure.errors).to eql(errors)
      end
    end

    describe "success?" do
      it { expect(described_class.new(true).success?).to be true }
      it { expect(described_class.new(false).success?).to be false }
    end
  end
end
