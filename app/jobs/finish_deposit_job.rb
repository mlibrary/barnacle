# frozen_string_literal: true

class FinishDepositJob < ApplicationJob
  def perform(deposit)
    Chipmunk::FinishDeposit.new(deposit).run
  end
end
