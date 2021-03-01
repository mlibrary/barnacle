# frozen_string_literal: true

Fabricator(:deposit) do
  user
  artifact
  status { Deposit.statuses[:started] }
end
