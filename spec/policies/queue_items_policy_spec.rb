# frozen_string_literal: true

RSpec.describe QueueItemsPolicy do
  context "as an admin" do
    let(:user) { FakeUser.new(admin?: true) }

    it_allows :index?, :new?
    it_resolves :all
  end

  context "as a persisted non-admin user" do
    let(:user) { FakeUser.new(admin?: false) }

    it_allows :index?, :new?
    it_resolves_owned
  end

  context "as an externally-identified user" do
    let(:user) { FakeUser.with_external_identity }
    let(:request) { double(:request, user: double) }

    it_disallows :index?, :new?
    it_resolves :none
  end

  it_has_base_scope(QueueItem.all)
end
