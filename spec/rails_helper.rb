# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end

Services.register(:incoming_storage) do
  Chipmunk::IncomingStorage.new(
    volume: Chipmunk::Volume.new(
      name: "incoming",
      reader: Chipmunk::Bag::Reader.new,
      writer: Chipmunk::Bag::MoveWriter.new,
      root_path: Chipmunk.config.upload.upload_path
    ),
    paths: Chipmunk::UploadPath.new("/"),
    links: Chipmunk::UploadPath.new(Chipmunk.config.upload["rsync_point"])
  )
end

Services.register(:storage) do
  Chipmunk::PackageStorage.new(volumes: [
    Chipmunk::Volume.new(
      name: "test",
      reader: Chipmunk::Bag::Reader.new,
      writer: Chipmunk::Bag::MoveWriter.new,
      root_path: Rails.root.join("spec/support/fixtures")
    ),
    Chipmunk::Volume.new(
      name: "bags",
      reader: Chipmunk::Bag::Reader.new,
      writer: Chipmunk::Bag::MoveWriter.new,
      root_path: Chipmunk.config.upload.storage_path
    )
  ])
end
