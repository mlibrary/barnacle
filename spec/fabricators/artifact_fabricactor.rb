# frozen_string_literal: true

Fabricator(:artifact) do
  id { SecureRandom.uuid }
  user { Fabricate(:user) }
  storage_format { ["bag", "bag:versioned"].sample }
  content_type { ["digital", "audio"].sample }
  revisions []
end
