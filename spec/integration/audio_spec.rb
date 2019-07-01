# frozen_string_literal: true

require "rails_helper"
require "fileutils"

RSpec.describe "audio validation integration", integration: true do
  it_behaves_like "a validation integration" do
    let(:content_type) { "audio" }
    let(:external_id) { "39015087086396" }
    let(:expected_error) { /ERROR - Missing file.*file: pm000001.wav/m }
  end
end
