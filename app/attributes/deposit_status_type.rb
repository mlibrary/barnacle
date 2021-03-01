# frozen_string_literal: true

class DepositStatusType < ActiveRecord::Type::Value
  def cast(value)
    super(value.to_s)
  end

  def deserialize(value)
    Chipmunk::DepositStatus.new(value)
  end

  def serialize(deposit_status)
    deposit_status.to_s
  end

end
