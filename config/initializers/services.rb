# frozen_string_literal: true

require "chipmunk"

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

Services = Canister.new
Services.register(:bag_storage) do
  Chipmunk::Bag::DiskStorage.new(Chipmunk.config.upload.storage_path)
end
Services.register(:packages) do
  Chipmunk::Package::Repository.new(adapters: { bag: bag_storage })
end
Services.register(:request_attributes) { Keycard::Request::AttributesFactory.new }
Services.register(:checkpoint) do
  Checkpoint::Authority.new(agent_resolver: KCV::AgentResolver.new)
end
