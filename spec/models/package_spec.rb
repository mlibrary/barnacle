# frozen_string_literal: true

require "rails_helper"

RSpec.describe Package, type: :model do
  let(:upload_path) { Rails.application.config.upload["upload_path"] }
  let(:upload_link) { Rails.application.config.upload["rsync_point"] }
  let(:storage_path) { Rails.application.config.upload["storage_path"] }
  let(:uuid) { "6d11833a-d5fd-44f8-9205-277218578901" }

  it_behaves_like "a depositable item" do
    let(:instance) { Fabricate.build(:package) }
  end

  [:bag_id, :user_id, :external_id, :format, :content_type].each do |field|
    it "#{field} is required" do
      expect(Fabricate.build(:package, field => nil)).not_to be_valid
    end
  end

  it "can be valid" do
    expect(Fabricate(:package)).to be_valid
  end

  [:bag_id, :external_id].each do |field|
    it "#{field} must be unique" do
      expect do
        2.times { Fabricate(:package, field.to_sym => "something") }
      end.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  it "is not valid with a bag id shorter than 6 characters" do
    package = Fabricate.build(:package, user: Fabricate(:user), bag_id: "short")
    expect(package).not_to be_valid
  end

  it "has an upload link based on the rsync point and bag id" do
    request = Fabricate.build(:package, bag_id: uuid)
    expect(request.upload_link).to eq(File.join(upload_link, uuid))
  end

  describe "#to_param" do
    it "uses the bag id" do
      bag_id = "made_up"
      expect(Fabricate.build(:package, bag_id: bag_id).to_param).to eq(bag_id)
    end
  end

  describe "#resource_type" do
    it "returns the content type" do
      package = Fabricate.build(:package, content_type: Faker::Lorem.word)
      expect(package.resource_type).to eq(package.content_type)
    end
  end

  describe Package::AnyPackage do
    let(:resolver) { Chipmunk::ResourceResolver.new }
    let(:any_package) { Package::AnyPackage.new }

    it "expands to all configured package types" do
      expect(resolver.expand(any_package).map {|r| r.token.to_s }).to include(
        "digital:(all)",
        "audio:(all)",
        "video:(all)",
        "video_game:(all)",
        "Package:(all)",
        "(all):(all)"
      )
    end

    it "converts to Package:(all)" do
      expect(resolver.convert(any_package).token.to_s).to eq("Package:(all)")
    end
  end
end
