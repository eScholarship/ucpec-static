# frozen_string_literal: true

RSpec.describe UCPECStatic::Commands::TEI::ToHTML, type: :command do
  it "processes TEI data" do
    expect_command!("tei", "to-html", spec_file_path("sample-tei.xml"), "--verbose") do |c|
      c.to_stdout(spec_file_read("sample-tei.html"))

      c.to_stderr(/Pipeline complete/)
    end
  end

  context "with non-TEI input" do
    it "halts" do
      expect_command!("tei", "to-html", __FILE__, "--verbose") do |c|
        c.to_stderr(/Invalid TEI document encountered: to_html_spec.rb/)
      end
    end
  end
end
