# frozen_string_literal: true

RSpec.describe Chipmunk::IncomingStorage do
  let(:reader) { double(:reader, format: "some-pkg") }
  let(:writer) { double(:writer, format: "some-pkg") }
  let(:volume) { Chipmunk::Volume.new(name: "incoming", writer: writer, reader: reader, root_path: "/incoming") }
  let(:path_builder) { Chipmunk::UploadPath.new("/") }
  let(:unstored_package) do
    instance_double(
      "Package",
      stored?: false,
      username: "uploader",
      bag_id: "abcdef-123456",
      identifier: "abcdef-123456"
)
  end
  let(:stored_package) { instance_double("Package", stored?: true) }

  subject(:storage) do
    described_class.new(
      volume: volume,
      paths: Chipmunk::UserUploadPath.new("/"),
      links: Chipmunk::UploadPath.new("rsync:foo")
    )
  end

  describe "#upload_link" do
    it "reports the upload link" do
      expect(storage.upload_link(unstored_package)).to eql("rsync:foo/#{unstored_package.bag_id}")
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
