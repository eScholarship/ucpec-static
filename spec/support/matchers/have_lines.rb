# frozen_string_literal: true

RSpec::Matchers.define :have_lines do |expected|
  match do |actual|
    @lines_count = line_count_for(actual)

    values_match?(expected, @lines_count)
  end

  failure_message do |actual|
    "expected #{expected} lines, got #{line_count_for(actual)}"
  end

  chain :non_empty do
    @non_empty = true
  end

  private

  # @param [#to_s] actual
  # @return [Integer]
  def line_count_for(actual)
    actual.to_s.lines.then { @non_empty ? _1.compact_blank : _1 }.count
  end
end
