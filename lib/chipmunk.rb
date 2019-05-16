# frozen_string_literal: true

module Chipmunk
end

require "semantic_logger"

require_relative "chipmunk/errors"
require_relative "chipmunk/validatable"

require_relative "chipmunk/package"
require_relative "chipmunk/bag"

require_relative "chipmunk/bag/profile"
require_relative "chipmunk/bag/tag"
require_relative "chipmunk/bag/disk_storage"
require_relative "chipmunk/bag/validator"
