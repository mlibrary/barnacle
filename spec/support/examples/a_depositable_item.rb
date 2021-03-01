# frozen_string_literal: true

RSpec.shared_examples "a depositable item" do
  let(:instance) { described_class.new }

  it "#identifier is a String" do
    expect(instance.identifier).to be_a_kind_of(String)
  end

  it "#username is a String" do
    expect(instance.username).to be_a_kind_of(String)
  end
end
