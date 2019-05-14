# frozen_string_literal: true

RSpec.describe QueueItemPolicy do
  let(:package) { double(:package, resource_type: 'audio', resource_id: 1) }
  let(:resource) { double(:resource, user: double(:user), resource_type: 'QueueItem', resource_id: 1, package: package) }

  context "as an admin" do
    let(:user) { FakeUser.admin }

    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "as a collection manager for the content type of the related package" do
    let(:user) { FakeUser.with_role('content_manager','audio') }

    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "as a collection manager for a content type not for the related packages" do
    let(:user) { FakeUser.with_role('content_manager','video') }

    it_disallows :show?, :update?, :destroy?
  end

  context "as a viewer for the content type of the related package" do
    let(:user) { FakeUser.with_role('viewer','audio') }

    it_allows :show?
    it_disallows :update?, :destroy?
  end

  context "as a viewer for the content type not for the related package" do
    let(:user) { FakeUser.with_role('viewer','video') }

    it_disallows :show?, :update?, :destroy?
  end

  context "as a user granted nothing" do
    let(:user) {  FakeUser.new }

    it_disallows :show?, :update?, :destroy?
  end
end
