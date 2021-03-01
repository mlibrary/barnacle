# frozen_string_literal: true

module Chipmunk
  class Bag
    class Reader
      def at(path)
        Chipmunk::Bag.new(path)
      end

      def storage_format
        Bag.storage_format
      end
    end
  end
end
