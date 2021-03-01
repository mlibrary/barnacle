# frozen_string_literal: true

require "pathname"

module Chipmunk
  # IncomingStorage is responsible for the business rules of writing to and reading
  # from Volumes earmarked for its use. It is specifically concerned with initial
  # upload of bags, and makes them available to other parts of the system via its
  # methods.
  class IncomingStorage

    # Create an IncomingStorage instance.
    # @param volume [Volume] The Volume from which the deposited depositable items
    #   should be ingested
    # @param paths [PathBuilder] A PathBuilder that returns a path on disk to the user
    #   upload location for a deposit, for a given depositable item.
    # @param links [PathBuilder] A PathBuilder that returns an rsync destination to
    #   which the user should upload, for a given depositable item.
    def initialize(volume:, paths:, links:)
      @volume = volume
      @paths = paths
      @links = links
    end

    def for(depositable)
      volume.get(upload_path(depositable))
    end

    def include?(depositable)
      volume.include?(upload_path(depositable))
    end

    def upload_link(depositable)
      links.for(depositable)
    end

    private

    def upload_path(depositable)
      paths.for(depositable)
    end

    attr_reader :volume, :paths, :links
  end
end
