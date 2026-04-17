# frozen_string_literal: true

require "webmock/rspec"
require "ruby_crewai"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:all) do
    CrewAI.configure do |c|
      c.access_token = ENV.fetch("CREWAI_ACCESS_TOKEN", "test-token")
      c.uri_base = ENV.fetch("CREWAI_URI_BASE", "https://test.crewai.com")
    end
  end
end
