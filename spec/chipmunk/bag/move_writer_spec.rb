# frozen_string_literal: true

# These tests were ported over from PackageStorage's specs.
RSpec.describe Chipmunk::Bag::MoveWriter do
  let(:bag) { double(:bag, path: "/some/bag/path") }
  let(:path) { "/bag/goes/in/here" }

  subject(:writer) { described_class.new }

  before(:each) do
    allow(FileUtils).to receive(:mkdir_p)
    allow(File).to receive(:rename)
  end

  it "ensures the desination directory exists" do
    expect(FileUtils).to receive(:mkdir_p).with(path)
    writer.write(bag, path)
  end

  it "moves the source to the destination directory" do
    expect(File).to receive(:rename).with(bag.path, path)
    writer.write(bag, path)
  end
end
