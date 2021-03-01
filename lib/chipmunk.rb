# frozen_string_literal: true

module Chipmunk
end

require "semantic_logger"

require_relative "chipmunk/errors"

require_relative "chipmunk/bag"
require_relative "chipmunk/deposit_status"
require_relative "chipmunk/resolvers"
require_relative "chipmunk/incoming_storage"
require_relative "chipmunk/package_storage"
require_relative "chipmunk/upload_path"
require_relative "chipmunk/user_upload_path"
require_relative "chipmunk/volume"
require_relative "chipmunk/validator"
require_relative "chipmunk/validation_service"
require_relative "chipmunk/finish_deposit"
