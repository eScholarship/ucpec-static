# frozen_string_literal: true

RSpec.describe UCPECStatic::Commands::TEI::ListKnownTags, type: :command do
  it "lists known tags" do
    expect_command!("tei", "list-known-tags", "--verbose") do |c|
      c.to_stdout(have_lines(70).non_empty)

      c.no_stderr!
    end
  end
end
