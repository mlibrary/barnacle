# frozen_string_literal: true

require "spec_helper"
require "policy_errors"
require_relative "policy_helpers"

RSpec.describe CollectionPolicy, type: :policy do
  let(:user) { double(:user) }

  describe "#base_scope" do
    it "returns an empty collection" do
      expect(described_class.new(user).base_scope).to eq(ApplicationRecord.none)
    end
  end

  describe "#resolve" do
    it "returns the original scope" do
      scope = double(:scope)
      expect(described_class.new(user, scope).resolve).to be(scope)
    end
  end

  it_disallows :index?, :create?

  describe "authorize!" do
    [:index?, :create?].each do |action|
      it "raises an exception for #{action}" do
        expect { described_class.new(user).authorize!(action) }.to raise_error(NotAuthorizedError)
      end
    end

    it "raises an exception for undefined action 'whatever?'" do
      expect { described_class.new(user).authorize(:whatever?) }.to raise_error(NoMethodError)
    end
  end
end
