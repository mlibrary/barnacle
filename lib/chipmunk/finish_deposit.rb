# frozen_string_literal: true

module Chipmunk
  class FinishDeposit
    def initialize(deposit)
      @deposit = deposit
      @errors = []
    end

    def run
      ingest! || record_failure
    end

    private

    attr_reader :deposit, :errors

    def ingest!
      validate && move_sip && record_success
    rescue StandardError => e
      log_exception(e)
    end

    def validate
      result = Services.validation.validate(deposit)
      errors.concat result.errors
      result.valid?
    end

    def move_sip
      sip = Services.incoming_storage.for(deposit)
      Services.storage.write(deposit.artifact, sip) do |volume|
        deposit.artifact.storage_volume = volume.name
      end
    end

    def record_success
      deposit.transaction do
        Revision.create!(deposit: deposit, artifact: deposit.artifact)
        deposit.complete!
        deposit.artifact.save!
      end
    end

    def record_failure
      deposit.fail!(errors)
    end

    def log_exception(exception)
      errors << "#{exception.backtrace.first}: #{exception.message} (#{exception.class})"
      errors << exception.backtrace.drop(1).map {|s| "\t#{s}" }
      record_failure
    end

  end
end
