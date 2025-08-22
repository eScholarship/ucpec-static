# frozen_string_literal: true

require "bundler/setup"

require "simplecov"

SimpleCov.start do
  enable_coverage :branch

  add_filter "lib/boot"
  add_filter "lib/ucpec_static/support"
  add_filter "spec/support"
end

require "ucpec_static"

module TestHelpers
  ROOT = Pathname(__dir__)

  SPEC_DATA = ROOT.join("data")

  module Types
    include Dry.Types
  end
end

TestHelpers::ROOT.glob("support/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end
