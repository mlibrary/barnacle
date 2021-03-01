# frozen_string_literal: true

require "pathname"

module Chipmunk

  # Generate upload paths for a given package using the id of the package.
  class UploadPath
    def initialize(root_path)
      @root_path = Pathname.new(root_path)
      raise ArgumentError, "root_path must not be nil" unless @root_path
    end

    def for(package)
      File.join(root_path, package.identifier)
    end

    private

    attr_reader :root_path
  end

end
