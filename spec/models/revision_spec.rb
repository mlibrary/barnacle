# frozen_string_literal: true

require "rails_helper"

RSpec.describe Revision, type: :model do
  it "has a valid fabricator" do
    expect(Fabricate.create(:revision)).to be_valid
  end

  it "has a valid fabriactor that doesn't save to the database" do
    expect(Fabricate.build(:revision)).to be_valid
  end
end
