# frozen_string_literal: true

RSpec::Matchers.define :match_tei_tag do |expected_tag|
  match do |actual_class|
    actual_class.matches_tei_tag?(expected_tag)
  end
end
