# frozen_string_literal: true

require "coveralls"
Coveralls.wear!("rails")

require "chipmunk"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_excluding integration: true unless ENV["RUN_INTEGRATION"]

  config.after(:each) do
    # Reset the unique generator used for usernames for each example
    ChipmunkFaker::Internet.clear
  end
end

require_relative "all_support"
require "webmock/rspec"

def fixture(*path)
  File.join(Rails.application.root, "spec", "support", "fixtures", File.join(*path))
end
