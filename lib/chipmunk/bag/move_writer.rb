# frozen_string_literal: true

module Chipmunk
  class Bag

    # Writes a bag by moving the source via file rename.
    class MoveWriter
      def write(bag, path)
        FileUtils.mkdir_p(path)
        File.rename(bag.path, path)
      end
    end

  end
end
