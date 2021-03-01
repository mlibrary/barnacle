# frozen_string_literal: true

RSpec.describe Chipmunk::Validator::Validator do
  class OnlyIfValidator < described_class
    def initialize(only_if: true)
      @only_if = only_if
    end

    validates "For testing only_if",
      only_if: proc { @only_if }, # rubocop:disable RSpec/InstanceVariable
      precondition: proc { true },
      condition: proc { false },
      error: proc { "injected_error" }
  end

  class PrecondValidator < described_class
    def initialize(precond)
      @precond = precond
    end

    validates "For testing preconditions",
      only_if: proc { true },
      precondition: proc { @precond }, # rubocop:disable RSpec/InstanceVariable
      condition: proc {|_, precond_result| precond_result },
      error: proc {|_, precond_result| "#{precond_result} injected_error" }
  end

  class BlockParamValidator < described_class
    validates "For testing that blocks receive the object being validated",
      only_if: proc {|v| v.called_by << :only_if; true },
      precondition: proc {|v| v.called_by << :precondition; true },
      condition: proc {|v| v.called_by << :condition; false },
      error: proc {|v| v.called_by << :error; "some_error" }
  end

  let(:validatable) { double(:validatable) }

  context "when only_if is true" do
    let(:failure) { OnlyIfValidator.new(only_if: true) }

    it "runs the validation" do
      expect(failure.valid?(validatable)).to be false
    end
  end

  context "when only_if is false" do
    let(:success) { OnlyIfValidator.new(only_if: false) }

    it "skips the validation" do
      expect(success.valid?(validatable)).to be true
    end
  end

  context "with a precondition" do
    let(:failure) { PrecondValidator.new(false) }

    it "passes the precondition to the condition" do
      expect(failure.valid?(validatable)).to be false
    end

    it "passes the precondition to the error" do
      expect(failure.errors(validatable)).to include("false injected_error")
    end
  end

  describe "each block receives the object being validated" do
    let(:validatable) { double(:validatable, called_by: []) }
    let(:failure) { BlockParamValidator.new }

    it "passes the validatable to each block" do
      failure.valid?(validatable)
      expect(validatable.called_by)
        .to contain_exactly(:only_if, :precondition, :condition, :error)
    end
  end
end
