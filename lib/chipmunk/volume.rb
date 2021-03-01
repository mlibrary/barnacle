# frozen_string_literal: true

require "pathname"

module Chipmunk
  # A named storage volume for a given format. This assumes for now that volumes
  # are accessible via normal disk (File/IO) operations.
  class Volume
    # @return [String] the name of the volume
    attr_reader :name

    # @return [Pathname] the absolute path to the storage root of the volume
    attr_reader :root_path

    # Create a new Volume.
    #
    # @param name [String] the name of the Volume; coerced to String
    # @param reader [Bag::Reader] A reader that can return the an instance of the
    #   stored object given a path.
    # @param root_path [String|Pathname] the path to the storage root for this Volume;
    #   must be absolute; coerced to Pathname
    # @raise [ArgumentError] if the name is blank or root_path is relative
    def initialize(name:, root_path:, reader: Chipmunk::Bag::Reader.new, writer:)
      @name = name.to_s
      @root_path = Pathname(root_path)
      @reader = reader
      @writer = writer
      validate!
    end

    # Expand a path within the volume for an absolute path on disk. Note that
    # this does not verify that the path is valid, just that it is localized to
    # storage volume. Any leading slashes will be flattened. The convention is
    # to pass absolute paths as if the volume were an isolated system.
    #
    # @param path [String|Pathname] the path to expand within the volume
    # @return [Pathname] the absolute path, suitable for File operations
    # @example Given a Volume with root_path of "/volume-root":
    #   volume.expand("/path/within/volume") # ==> Pathname("/volume-root/path/within/volume")
    def expand(path)
      (root_path/trim(path)).to_s
    end

    # Get the archive/package stored in this volume at a given path.
    #
    # @param [String] the path to the package within the volume to retrieve
    # @return [Chipmunk::Bag] a storage proxy for the package
    # @raise [Chipmunk::PackageNotFoundError] if there is no package stored at the given path
    def get(path)
      raise Chipmunk::PackageNotFoundError unless include?(path)

      reader.at(expand(path))
    end

    def write(object, path)
      writer.write(object, expand(path))
    end

    def include?(path)
      File.exist?(expand(path))
    end

    # @!attribute [r]
    #   @return [String] the format name of the items in this volume
    def storage_format
      reader.storage_format
    end
    alias_method :format, :storage_format

    private

    def validate!
      raise ArgumentError, "Volume name must not be blank" if name.strip.empty?
      raise ArgumentError, "Volume root_path must be absolute (#{root_path})" unless root_path.absolute?
      raise ArgumentError, "Volume must specify a reader" unless reader
      raise ArgumentError, "Volume must specify a writer" unless writer
    end

    # Remove any leading slashes so Pathname joins properly
    def trim(path)
      path.to_s.sub(/^\/*/, "")
    end

    attr_reader :reader, :writer
  end
end
