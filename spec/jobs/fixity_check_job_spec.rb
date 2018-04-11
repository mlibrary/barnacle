# frozen_string_literal: true

require "rails_helper"

RSpec.describe FixityCheckJob do
  let(:package) { Fabricate(:bag) }
  let(:user) { Fabricate(:user) }
  subject(:event) { package.events.last }

  def run_job
    described_class.perform_now(package, user, bag: bag)
  end

  shared_examples_for "a fixity check job" do |outcome|
    it "records a fixity check event" do
      run_job
      expect(event.event_type).to eq("fixity check")
    end
    it "records the user that ran the fixity check" do
      run_job
      expect(event.user).to eq(user)
    end
    it "records #{outcome}" do
      run_job
      expect(event.outcome).to eq(outcome.to_s)
    end
  end

  context "when the bag is valid" do
    let(:bag) { double(:bag, valid?: true) }

    it_behaves_like "a fixity check job", "success"
  end

  context "when the bag is not valid" do
    let(:bag) do
      double(:bag, valid?: false,
       errors: double("errors", full_messages: ["a specific error"]))
    end

    it_behaves_like "a fixity check job", "failure"

    it "records the error" do
      run_job
      expect(event.detail).to match("a specific error")
    end
  end

  context "when the fixity check raises an exception" do
    let(:bag) { double(:bag) }
    before(:each) { allow(bag).to receive(:valid?).and_raise(RuntimeError) }

    it_behaves_like "a fixity check job", "failure"

    it "records the error" do
      run_job
      expect(event.detail).to match("RuntimeError")
    end
  end
end
