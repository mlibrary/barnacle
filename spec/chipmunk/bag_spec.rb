# frozen_string_literal: true

RSpec.describe Chipmunk::Bag do
  # set up data in safe area
  around(:each) do |example|
    Dir.mktmpdir do |tmp_dir|
      @empty_path = Pathname.new(tmp_dir)/"emptybag"
      FileUtils.mkdir_p @empty_path
      @stored_path = Pathname.new(tmp_dir)/"test_bag"
      FileUtils.cp_r(Rails.root/"spec"/"support"/"fixtures"/"test_bag", @stored_path)
      example.run
    end
  end

  let(:empty_path) { @empty_path }
  let(:stored_path) { @stored_path }
  let(:empty_bag) { described_class.new(@empty_path) }
  let(:stored_bag) { described_class.new(@stored_path) }

  let(:stored_files) do
    Dir.glob(stored_path/"**"/"*")
      .map {|f| Pathname.new(f) }
      .reject(&:directory?)
  end

  describe "#bag_dir" do
    it "returns the bag dir path" do
      expect(stored_bag.bag_dir).to eql(stored_path)
    end
  end

  describe "#data_dir" do
    it "returns the data dir path" do
      expect(stored_bag.data_dir).to eql(stored_path/"data")
    end
  end

  describe "#format" do
    it "has the same format as the class" do
      expect(stored_bag.format).to eql(described_class.format)
      expect(stored_bag.format).to eql("bag")
    end
  end

  describe "#id" do
    it "returns the Bag-ID from the chipmunk-info.txt" do
      expect(stored_bag.id).to eql("14d25bcd-deaf-4c94-add7-c189fdca4692")
    end
  end

  describe "#content_type" do
    it "returns the Chipmunk-Content-Type from the chipmunk-info.txt" do
      expect(stored_bag.content_type).to eql("audio")
    end
  end

  describe "#external_id" do
    it "returns the External-Identifier from the chipmunk-info.txt" do
      expect(stored_bag.external_id).to eql("test_ex_id_22")
    end
  end

  describe "#files" do
    it "returns all the files" do
      expect(stored_bag.files).to contain_exactly(*stored_files)
    end
  end

  describe "#relative_files" do
    it "returns the files relative to the root of the bag" do
      relative_files = stored_files.map {|f| f.relative_path_from(stored_path) }
      expect(stored_bag.relative_files).to contain_exactly(*relative_files)
    end
  end

  describe "#data_files" do
    it "returns the files in the data directory" do
      expect(stored_bag.data_files).to contain_exactly(stored_path/"data"/"samplefile")
    end
  end

  describe "#relative_data_files" do
    it "returns the data files relative to the data directory" do
      expect(stored_bag.relative_data_files).to contain_exactly(Pathname.new("samplefile"))
    end
  end

  describe "#data_file!" do
    it "returns the full path for a given file in the data directory" do
      expect(stored_bag.data_file!("samplefile")).to eql(stored_path/"data"/"samplefile")
    end

    it "returns the appropriate mime type" do
      expect(stored_bag.data_file!("samplefile").type).to eql("application/octet-stream")
    end

    it "raises a FileNotFound exception if a file is requested that isn't in the data directory" do
      expect { stored_bag.data_file!("nonexistent") }.to raise_error(Chipmunk::FileNotFoundError)
    end

    it "raises a FileNotFound exception for traversal attempts" do
      expect { stored_bag.data_file!("../data/samplefile") }.to raise_error(Chipmunk::FileNotFoundError)
    end
  end

  describe "#chipmunk_info" do
    context "with no chipmunk-info.txt" do
      it "returns an empty hash" do
        expect(empty_bag.chipmunk_info).to eq({})
      end
    end

    context "with contents in chipmunk-info.txt" do
      let(:metadata_url) { "http://whatever/foo.txt" }
      let(:metadata_file) { "whatever.txt" }

      let(:info_hash) do
        { "Metadata-URL"     => metadata_url,
          "Metadata-Tagfile" => metadata_file }
      end

      let(:info_txt) do
        <<~TXT
          Metadata-URL: #{metadata_url}
          Metadata-Tagfile: #{metadata_file}
        TXT
      end

      before(:each) { File.write(empty_path/"chipmunk-info.txt", info_txt) }

      it "returns a hash of its contents" do
        expect(empty_bag.chipmunk_info).to eq(info_hash)
      end
    end
  end
end
