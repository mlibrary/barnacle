# frozen_string_literal: true

module Chipmunk
  # PackageStorage is a factory for proxies to a Package's underlying storage.
  # An instance supports a named set of format types, mapping each to a storage
  # proxy class and creating an appropriate proxy instance for a package.
  class PackageStorage

    # Create a PackageStorage instance.
    #
    # @param volumes [Array<Chipmunk::Volume>] the storage volumes where packages are stored
    def initialize(volumes:)
      @volumes = Hash[volumes.map {|volume| [volume.name, volume] }]
    end

    # Retrieve the storage proxy for a given package. The package must be stored and of a registered format.
    # @param package [Package] the package for which to retrieve a storage proxy
    # @raise [Chipmunk::PackageNotStoredError] if the package is not stored
    # @raise [Chipmunk::UnsupportedFormatError] if the package format is not registered
    def for(package)
      raise Chipmunk::PackageNotStoredError, package unless package.stored?

      # This is backwards compatibility for Package#storage_path. Otherwise, we
      # construct the storage path from the package's identifier. Package#storage_path
      # is safe to remove now, but is nontrivial to do so.
      storage_path = if package.respond_to?(:storage_path)
        package.storage_path
      else
        storage_path_for(package)
      end
      volume_for(package).get(storage_path)
    end

    # Move the source archive into preservation storage and update the package's
    # storage_volume and storage_path accordingly.
    def write(package, source)
      volume = destination_volume(package)
      storage_path = storage_path_for(package)
      volume.write(source, storage_path)
      yield volume, storage_path
    end

    private

    def storage_path_for(package)
      prefixes = package.identifier.match(/^(..)(..)(..).*/)
      raise "identifier too short: #{package.identifier}" unless prefixes

      File.join("/", prefixes[1..3], package.identifier)
    end

    # We are defaulting everything to "bags" for now as the simplest resolution strategy.
    def destination_volume(package)
      volumes["bags"].tap do |volume|
        raise Chipmunk::VolumeNotFoundError, "Cannot find destination volume: bags" if volume.nil?

        unsupported_format!(volume, package) if volume.storage_format != package.storage_format
      end
    end

    def volume_for(package)
      volumes[package.storage_volume].tap do |volume|
        raise Chipmunk::VolumeNotFoundError, package.storage_volume if volume.nil?

        unsupported_format!(volume, package) if volume.storage_format != package.storage_format
      end
    end

    def unsupported_format!(volume, package)
      raise Chipmunk::UnsupportedFormatError, "Volume #{volume.name} does not support #{package.storage_format}"
    end

    attr_reader :volumes
  end
end
