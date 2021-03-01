# frozen_string_literal: true

RSpec.describe Chipmunk::ValidationResult do
  describe "#valid?" do
    it "is valid when there are no errors" do
      expect(described_class.new([]).valid?).to be true
    end
    it "is invalid when there are errors" do
      expect(described_class.new([1]).valid?).to be false
    end
  end

  describe "#errors" do
    it "returns the errors" do
      expect(described_class.new(["error"]).errors).to eql(["error"])
    end

    it "handles un-nested errors" do
      expect(described_class.new("error").errors).to eql(["error"])
    end

    it "handles overly nested errors" do
      expect(described_class.new([["error"]]).errors).to eql(["error"])
    end

    it "removes nils" do
      expect(described_class.new([nil, "error"]).errors).to eql(["error"])
    end
  end
end
