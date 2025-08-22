# frozen_string_literal: true

RSpec.describe UCPECStatic::Commands::TEI::ToHTML, type: :command do
  it "processes TEI data" do
    expect_command!("tei", "to-html", spec_file_path("sample-tei.xml"), "--verbose") do |c|
      # For now
      c.no_stdout!

      c.to_stderr(/Pipeline complete/)
    end
  end
end
