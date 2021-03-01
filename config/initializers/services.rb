# frozen_string_literal: true

require "chipmunk"
require "rails"

def assign_db(lhs, rhs)
  if rhs.is_a? String
    lhs.url = rhs
  elsif rhs.respond_to?(:has_key?)
    if rhs["url"]
      lhs.url = rhs["url"]
    else
      lhs.opts = rhs
    end
  end
end

assign_db(Checkpoint::DB.config, Chipmunk.config.checkpoint.database)
assign_db(Keycard::DB.config, Chipmunk.config.keycard.database)

if Chipmunk.config.keycard&.access
  Keycard.config.access = Chipmunk.config.keycard.access
end

Chipmunk.config.upload.tap do |upload|
  ["upload_path", "storage_path"].each do |option|
    path = upload[option].to_s.strip
    raise ArgumentError, "Configuration option upload.#{option} must not be empty" if path.empty?

    upload[option] = Rails.root.join(path).to_s unless path.start_with?("/")
  end
end

# TODO: consult the environment-specific configuration for a set of volumes
Services = Canister.new
Services.register(:incoming_storage) do
  Chipmunk::IncomingStorage.new(
    volume: Chipmunk::Volume.new(
      name: "incoming",
      reader: Chipmunk::Bag::Reader.new,
      writer: Chipmunk::Bag::MoveWriter.new,
      root_path: Chipmunk.config.upload.upload_path
    ),
    paths: Chipmunk::UserUploadPath.new("/"),
    links: Chipmunk::UploadPath.new(Chipmunk.config.upload["rsync_point"])
  )
end

Services.register(:storage) do
  Chipmunk::PackageStorage.new(volumes: [
    Chipmunk::Volume.new(
      name: "root",
      reader: Chipmunk::Bag::Reader.new,
      writer: Chipmunk::Bag::MoveWriter.new,
      root_path: "/" # For migration purposes
    ),
    Chipmunk::Volume.new(
      name: "bags",
      reader: Chipmunk::Bag::Reader.new,
      writer: Chipmunk::Bag::MoveWriter.new,
      root_path: Chipmunk.config.upload.storage_path
    )
  ])
end

Services.register(:validation) { Chipmunk::ValidationService.new }

Services.register(:checkpoint) do
  Checkpoint::Authority.new(agent_resolver: KCV::AgentResolver.new,
                            credential_resolver: Chipmunk::RoleResolver.new,
                            resource_resolver: Chipmunk::ResourceResolver.new)
end

Services.register(:notary) { Keycard::Notary.default }
Services.register(:uuid_format) do
  /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i
end
