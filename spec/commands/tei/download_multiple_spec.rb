# frozen_string_literal: true

RSpec.describe UCPECStatic::Commands::TEI::DownloadMultiple, type: :command do
  include_context "tmpdir"

  let(:base_url) { "https://test.example.com" }

  before do
    stub_request(:get, "#{base_url}/sample-tei.xml")
      .to_return(status: 200, body: spec_file_read("sample-tei.xml"), headers: {})

    stub_request(:get, "#{base_url}/small-tei.xml")
      .to_return(status: 200, body: spec_file_read("small-tei.xml"), headers: {})

    stub_request(:get, "#{base_url}/nonexistent.xml")
      .to_return(status: 404, body: "Not Found", headers: {})
  end

  it "downloads multiple files" do
    list_path = tmpdir.join("download_list.txt")
    File.write(list_path, <<~TEXT)
    sample-tei.xml
    small-tei.xml
    nonexistent.xml
    TEXT

    output_dir = tmpdir.join("tei_output")

    downloaded_file = output_dir.join("sample-tei.xml")

    existing_file = output_dir.join("small-tei.xml")

    output_dir.mkpath

    existing_file.write(spec_file_read("small-tei.xml"))

    expect_command!("tei", "download-multiple", base_url, list_path.to_s, "--output-path", output_dir.to_s) do |c|
      c.effect! change(downloaded_file, :exist?).from(false).to(true)

      c.no_stdout!

      c.to_stderr(/Downloading/)
    end
  end
end
