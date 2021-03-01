# frozen_string_literal: true

RSpec.describe Chipmunk::PackageStorage do
  FakeBag = Struct.new(:storage_path) do
    def self.storage_format
      "bag"
    end
  end

  FakeZip = Struct.new(:storage_path) do
    def self.storage_format
      "zip"
    end
  end

  class FakeBagReader
    def storage_format
      "bag"
    end

    def at(path)
      FakeBag.new(path)
    end
  end

  class FakeZipReader
    def storage_format
      "zip"
    end

    def at(path)
      FakeZip.new(path)
    end
  end

  class FakeBagWriter
    def write(_obj, _path)
      nil
    end
  end
  FakeZipWriter = FakeBagWriter

  # TODO: Set up a "test context" that has realistic, but test-focused
  # services registered. This will offload setup of the environment from
  # various tests. This may be as simple as registering test components over
  # top of those configured in the services initializer when Rails.env is
  # test. Alternatively, it may be that shared contexts would configure sets
  # of components and stub the services container to yield them based on
  # inclusion of specific contexts in tests that need them. In this group,
  # the volumes and volume manager can be considered environmental, while the
  # packages are scenario data.
  let(:bags) do
    Chipmunk::Volume.new(
      name: "bags",
      root_path: "/bags",
      reader: FakeBagReader.new,
      writer: FakeBagWriter.new
    )
  end

  let(:zips) do
    Chipmunk::Volume.new(
      name: "zips",
      root_path: "/zips",
      reader: FakeZipReader.new,
      writer: FakeZipWriter.new
    )
  end

  before(:each) do
    allow(bags).to receive(:include?).with("/a-bag").and_return true
    allow(zips).to receive(:include?).with("/a-zip").and_return true
  end

  context "with two storage_formats registered: bag and zip" do
    let(:storage)   { described_class.new(volumes: [bags, zips]) }

    let(:storage_formats) { { bag: FakeBag, zip: FakeZip } }
    let(:bag)       { stored_package(storage_format: "bag", storage_volume: "bags", storage_path: "/a-bag") }
    let(:zip)       { stored_package(storage_format: "zip", storage_volume: "zips", storage_path: "/a-zip") }
    let(:transient) { unstored_package(storage_format: "bag", id: "abcdef-123456") }
    let(:badvolume) { stored_package(storage_format: "bag", storage_volume: "notfound") }

    let(:bag_proxy) { storage.for(bag) }
    let(:zip_proxy) { storage.for(zip) }

    it "creates a bag proxy for a bag package" do
      expect(bag_proxy).to be_a FakeBag
    end

    it "uses the bag volume for a bag" do
      expect(bag_proxy).to eq FakeBag.new("/bags/a-bag")
    end

    it "creates zip proxy for a zip package" do
      expect(zip_proxy).to be_a FakeZip
    end

    it "uses the zip volume for a zip" do
      expect(zip_proxy).to eq FakeZip.new("/zips/a-zip")
    end

    it "raises an error for unstored package" do
      expect { storage.for(transient) }.to raise_error(Chipmunk::PackageNotStoredError)
    end

    it "raises an error for a bad volume" do
      expect { storage.for(badvolume) }.to raise_error(Chipmunk::VolumeNotFoundError)
    end
  end

  describe "writing a package" do
    context "with a good bag" do
      subject(:storage) { described_class.new(volumes: [bags]) }

      let(:package)  { spy(:package, storage_format: "bag", identifier: "abcdef-123456") }
      let(:disk_bag) { double(:bag, path: "/uploaded/abcdef-123456") }

      it "moves the source bag to the destination directory" do
        # TODO: This test is probably less specific than originally intended; setting
        # an expection also adds an implicit allow(...) for the expectation. Here,
        # originally it just expected File.rename to be called, regardless of args.
        # Indeed, there seems to be a bit of a mismatch with these arguments across
        # the few files concerned with it; somtimes they're bags, sometimes they're
        # paths. We should be careful to make that clear so no issues get past
        # testing. For the time being, I have left the expectation with the original
        # specificity.
        expect(bags).to receive(:write)
        storage.write(package, disk_bag) {}
      end

      it "yields the storage_volume" do
        storage.write(package, disk_bag) do |actual_storage_volume, _|
          expect(actual_storage_volume).to eql(bags)
        end
      end

      it "yields the storage_path" do
        storage.write(package, disk_bag) do |_, actual_storage_path|
          expect(actual_storage_path).to eql("/ab/cd/ef/abcdef-123456")
        end
      end
    end

    context "with a badly identified bag (shorter than 6 chars)" do
      subject(:storage) { described_class.new(volumes: [bags]) }

      let(:package)  { double(:package, storage_format: "bag", identifier: "ab12") }
      let(:disk_bag) { double(:bag, path: "/uploaded/ab12") }

      it "raises an exception" do
        expect { storage.write(package, disk_bag) }.to raise_error RuntimeError
      end
    end

    context "with an unsupported archive storage_format" do
      subject(:storage) { described_class.new(volumes: [bags]) }

      let(:package) { double(:package, storage_format: "junk", identifier: "id") }
      let(:archive) { double(:archive) }

      it "raises an Unsupported Format error" do
        expect { storage.write(package, archive) }.to raise_error(Chipmunk::UnsupportedFormatError, /junk/)
      end
    end
  end

  def stored_package(storage_format:, storage_volume: "test", storage_path: "/path")
    double(:package, stored?: true, storage_format: storage_format.to_s, storage_volume: storage_volume, storage_path: storage_path)
  end

  def unstored_package(storage_format:, id:)
    double(:package, stored?: false, storage_volume: nil, storage_path: nil, storage_format: storage_format, identifier: id)
  end
end
