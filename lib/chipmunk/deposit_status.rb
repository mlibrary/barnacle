# frozen_string_literal: true

module Chipmunk

  class DepositStatus

    VALUES = [
      :started,
      :canceled,
      :ingesting,
      :failed,
      :completed
    ].freeze

    # Define a constructor for each value, e.g. DepositStatus.started
    class << self
      VALUES.each do |value|
        define_method(value) do
          new(value)
        end
      end
    end

    # Define a predicate method #value? for each value, e.g. #completed?
    VALUES.each do |value|
      define_method(:"#{value}?") do
        self.value == value
      end
    end

    def initialize(value)
      @value = value.to_sym
      unless VALUES.include?(@value)
        raise ArgumentError, "Invalid value #{value}, expected one of #{VALUES}"
      end
    end

    def eql?(other)
      value == other.value
    end

    def to_s
      value.to_s
    end

    def to_sym
      value
    end

    def alive?
      started? || ingesting?
    end

    def dead?
      !alive?
    end

    private

    attr_reader :value

  end

end
