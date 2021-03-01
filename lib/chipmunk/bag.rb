# frozen_string_literal: true

require "bagit"

module Chipmunk
  class Bag
    include SemanticLogger::Loggable

    class << self
      def format
        "bag"
      end
      alias_method :storage_format, :format
    end

    def initialize(path, info = {}, _create = false)
      @bag = BagIt::Bag.new(path, info, _create)
    end

    def format
      self.class.format
    end
    alias_method :storage_format, :format

    def path
      bag_dir.to_s
    end

    def bag_dir
      Pathname.new(super)
    end

    def data_dir
      Pathname.new(super)
    end

    def chipmunk_info_txt_file
      bag_dir/"chipmunk-info.txt"
    end

    def chipmunk_info
      return {} unless File.exist?(chipmunk_info_txt_file)

      logger.debug "Delegating method 'read_info_file' to bag, caller: #{caller(1..1).first}"
      bag.send(:read_info_file, chipmunk_info_txt_file)
    end

    def id
      chipmunk_info.fetch("Bag-ID")
    end

    def content_type
      chipmunk_info.fetch("Chipmunk-Content-Type")
    end

    def external_id
      chipmunk_info.fetch("External-Identifier")
    end

    # Get the absolute paths of all files
    def files
      Dir.glob(bag_dir/"**"/"*")
        .map {|f| Pathname.new(f) }
        .reject(&:directory?)
    end

    # Get the paths of all files relative to the root of the bag
    # @see {#bag_dir}
    def relative_files
      files.map {|f| f.relative_path_from(bag_dir) }
    end

    # Get the absolute paths of the files under the data directory
    def data_files
      bag.bag_files.map {|f| Pathname.new(f) }
    end

    # Get the paths of the data files relative to the data directory
    # @see {#data_dir}
    def relative_data_files
      data_files.map {|f| f.relative_path_from(data_dir) }
    end

    # Test if the bag contains a data file
    # @param path [Pathname|String] Path of the file relative to the data directory
    # @see {#data_dir}
    def includes_data?(path)
      relative_data_files.include?(Pathname.new(path))
    end

    # Test if the bag contains a path
    # @param path [Pathname|String] Path to the file relative to the bag root.
    # @see {#bag_dir}
    def includes?(path)
      relative_files.include?(Pathname.new(path))
    end

    # Get a reference to a data file in the bag
    # @param path [Pathname] Relative path to the file
    def data_file!(path)
      path = Pathname.new(path)
      if relative_data_files.include?(path)
        data_dir/path
      else
        raise FileNotFoundError, "No such file #{path} in bag"
      end
    end

    def method_missing(name, *args, &block)
      if @bag.respond_to?(name)
        logger.debug "Delegating method '#{name}' to bag, caller: #{caller(1..1).first}"
        @bag.send(name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      bag.respond_to?(name) || super
    end

    private

    attr_reader :bag
  end
end

require_relative "bag/profile"
require_relative "bag/reader"
require_relative "bag/move_writer"
require_relative "bag/tag"
