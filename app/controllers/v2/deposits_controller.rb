# frozen_string_literal: true

module V2
  class DepositsController < ResourceController

    def create
      # TODO policy check
      @deposit = Deposit.create!(
        artifact: Artifact.find(params[:artifact_id]),
        user: current_user,
        status: :started
      )
      # TODO: don't pick a specific template
      render "v2/deposits/show", status: 201, location: v2_deposit_path(@deposit)
    end

    def ready
      # TODO policy check
      @deposit = Deposit.find(params[:id])
      case @deposit.status
      when Deposit.statuses[:started]
        @deposit.update!(status: Deposit.statuses[:ingesting])
        FinishDepositJob.perform_later(@deposit)
        render json: @deposit, status: 200
      when Deposit.statuses[:ingesting]
        render json: @deposit, status: 200
      else # :completed, :failed, :cancelled
        head 422 # TODO think about this response
      end
    end

  end
end
