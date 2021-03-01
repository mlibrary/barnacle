# frozen_string_literal: true

require "pathname"

RSpec.describe Chipmunk::Volume do
  subject(:volume) do
    described_class.new(
      name: name,
      root_path: root_path,
      reader: reader,
      writer: writer
    )
  end

  context "when given valid attributes" do
    let(:name)         { "vol" }
    let(:proxy)        { double(:storage_proxy) }
    let(:reader)       { double(:reader, at: proxy, storage_format: "some-pkg") }
    let(:writer)       { double(:writer, write: nil) }
    let(:root_path)    { "/path" }

    it "has the correct name" do
      expect(volume.name).to eq "vol"
    end

    it "has the correct format" do
      expect(volume.format).to eq "some-pkg"
    end

    it "has the correct storage_format" do
      expect(volume.storage_format).to eq "some-pkg"
    end

    it "has the correct root path" do
      expect(volume.root_path).to eq Pathname("/path")
    end

    it "expands relative paths correctly" do
      expect(volume.expand("foo/bar")).to eq "/path/foo/bar"
    end

    it "expands absolute paths correctly" do
      expect(volume.expand("/foo/bar")).to eq "/path/foo/bar"
    end

    describe "getting packages" do
      before(:each) do
        allow(File).to receive(:exist?).and_return false
        allow(File).to receive(:exist?).with("/path/existent").and_return true
      end

      it "reports existent packages as included" do
        expect(volume.include?("/existent")).to eq true
      end

      it "reports nonexistent packages as missing" do
        expect(volume.include?("/nonexistent")).to eq false
      end

      it "creates a storage proxy for an existent path" do
        expect(volume.get("/existent")).to eq proxy
      end

      it "raises an error when trying to get a nonexistent package" do
        expect { volume.get("/nonexistent") }.to raise_error(Chipmunk::PackageNotFoundError)
      end
    end
  end

  context "when given a blank name" do
    let(:name) { "" }
    let(:reader) { double(:reader, at: nil, format: "some-pkg") }
    let(:writer)       { double(:writer, write: nil, format: "some-pkg") }
    let(:root_path)    { "/path" }

    it "raises an argument error that the name must not be blank" do
      expect { volume }.to raise_error(ArgumentError, /name.*blank/)
    end
  end

  context "when given a relative path" do
    let(:name) { "vol" }
    let(:reader) { double(:reader, at: nil, format: "some-pkg") }
    let(:writer)       { double(:writer, write: nil, format: "some-pkg") }
    let(:root_path)    { "relative/path" }

    it "raises an argument error that path must be absolute" do
      expect { volume }.to raise_error(ArgumentError, /path.*absolute/)
    end
  end
end
