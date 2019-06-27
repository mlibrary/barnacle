# frozen_string_literal: true

RSpec.describe Chipmunk::IncomingStorage do
  subject(:storage) { described_class.new(volume: volume, paths: path_builder, links: path_builder) }
  subject(:storage) do
    described_class.new(
      volume: volume,
      paths: described_class::UserPathBuilder.new("/"),
      links: described_class::IdPathBuilder.new("rsync:foo")
    )
  end

  let(:package_type) { double("SomePackageFormat", format: "some-pkg") }
  let(:volume) { Chipmunk::Volume.new(name: "incoming", package_type: package_type, root_path: "/incoming") }
  let(:path_builder) { Chipmunk::IncomingStorage::IdPathBuilder.new("/") }

  let(:uploader)         { instance_double("User", username: "uploader") }
  let(:unstored_package) { instance_double("Package", stored?: false, user: uploader, bag_id: "abcdef-123456") }
  let(:stored_package)   { instance_double("Package", stored?: true) }

  describe "#upload_link" do
    it "reports the upload link" do
      expect(storage.upload_link(unstored_package)).to eql("rsync:foo/#{unstored_package.bag_id}")
    end
  end

  context "with a package that is already in preservation" do
    it "raises an already-stored error" do
      expect { storage.for(stored_package) }.to raise_error(Chipmunk::PackageAlreadyStoredError)
    end
  end

  context "with a package that is uploaded to a user's directory (not yet in preservation)" do
    let(:incoming_bag) { double(:bag) }

    before(:each) do
      allow(volume).to receive(:get).and_return(incoming_bag)
      allow(volume).to receive(:include?).with("/uploader/abcdef-123456").and_return(true)
    end

    it "creates a storage proxy for the incoming package" do
      expect(storage.for(unstored_package)).to eq incoming_bag
    end

    it "reports that the incoming package exists" do
      expect(storage.include?(unstored_package)).to eq true
    end
  end
end
