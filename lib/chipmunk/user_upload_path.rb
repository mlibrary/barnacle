# frozen_string_literal: true

require "chipmunk"

module Chipmunk

  # Generate upload paths from a package's id and user
  class UserUploadPath
    def initialize(root_path)
      @root_path = Pathname.new(root_path)
      raise ArgumentError, "root_path must not be nil" unless @root_path
    end

    def for(package)
      File.join(root_path, package.username, package.identifier)
    end

    private

    attr_reader :root_path
  end

end
