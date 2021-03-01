# frozen_string_literal: true

require "rails_helper"

RSpec.describe Deposit, type: :model do
  it_behaves_like "a depositable item" do
    let(:instance) { Fabricate.build(:deposit) }
  end

  it "has a valid fabricator" do
    expect(Fabricate.create(:deposit)).to be_valid
  end

  it "has a valid fabriactor that doesn't save to the database" do
    expect(Fabricate.build(:deposit)).to be_valid
  end

  describe "#storage_format" do
    let(:deposit) { Fabricate.build(:deposit) }

    it "uses the artifact's storage_format" do
      expect(deposit.storage_format).to eql(deposit.artifact.storage_format)
    end
  end

  describe "#fail!" do
    let(:deposit) { Fabricate.create(:deposit) }
    let(:error) { ["some", "errors"] }

    it "updates with status failed" do
      expect { deposit.fail!(error) }
        .to change(deposit, :status)
        .to("failed")
    end

    it "updates with the error" do
      expect { deposit.fail!(error) }
        .to change(deposit, :error)
        .to("some\nerrors")
    end

    it "saves the record" do
      deposit.fail!(error)
      expect(deposit.changed?).to be false
    end
  end
end
