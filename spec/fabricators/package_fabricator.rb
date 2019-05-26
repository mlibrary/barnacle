# frozen_string_literal: true

Fabricator(:package, aliases: [:request]) do
  bag_id { SecureRandom.uuid }
  user { Fabricate(:user) }
  external_id { SecureRandom.uuid }
  format { "bag" }
  storage_location { File.join Faker::Lorem.word, Faker::Lorem.word, Faker::Lorem.word }
  storage_volume { "root" }
  content_type { ["digital", "audio"].sample }
end

Fabricator(:stored_package, from: :package) do
  storage_location { Rails.root/"spec"/"support"/"fixtures"/"test_bag" }
  storage_volume { "root" }
end

Fabricator(:unstored_package, from: :package) do
  storage_location { nil }
  storage_volume { nil }
end
