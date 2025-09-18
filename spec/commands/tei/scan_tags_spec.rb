# frozen_string_literal: true

RSpec.describe UCPECStatic::Commands::TEI::ScanTags, type: :command do
  include_context "tmpdir"

  let(:sample_tei_content) { spec_file_read("small-tei.xml") }

  let(:tei_dir) { tmpdir.join("tei") }
  let(:db_path) { tmpdir.join("tags.sqlite3") }

  let(:file1) { tei_dir.join("file1.xml") }
  let(:file2) { tei_dir.join("file2.xml") }

  # @return [SQLite3::Database]
  attr_reader :db

  before do
    tei_dir.mkpath

    file1.write(sample_tei_content)

    # This file should be ignored.
    file2.write(<<~XML)
    <?xml version="1.0" encoding="UTF-8"?>
    <non-tei>
      <body>
        <p>This is not TEI.</p>
      </body>
    </non-tei>
    XML
  end

  after do
    db&.close

    db_path.unlink if db_path.exist?

    tei_dir.rmtree if tei_dir.exist?
  end

  it "scans TEI tags from a directory of TEI XML files" do
    expect_command!("tei", "scan-tags", "--directory", tei_dir, "--db-path", db_path, "--fresh") do |c|
      c.effect! change(db_path, :exist?).from(false).to(true)

      c.no_stdout!

      c.to_stderr(/Scanning TEI/)
    end

    # @note We use an instance variable here
    #   so that the `after` block can access it.
    #   We do not want to take a chance that `let` memoization
    #   will create a SQLIte3::Database before we want it to.
    @db = SQLite3::Database.new(db_path)

    aggregate_failures do
      tags = db.execute("SELECT name, SUM(occurrences) FROM tags WHERE kind = 'body' GROUP BY name ORDER BY name;")

      expect(tags).to eq([
                           ["body", 1],
                           ["hi", 1],
                           ["p", 2],
                           ["quote", 1],
                           ["seg", 1],
                           ["sp", 1],
                           ["speaker", 1],
                           ["text", 1]
                         ])

      hi_attrs = db.execute("SELECT attr_name FROM tag_attrs WHERE tag_name = 'hi' ORDER BY attr_name;")
      expect(hi_attrs).to eq([["rend"]])

      quote_attrs = db.execute("SELECT attr_name FROM tag_attrs WHERE tag_name = 'quote' ORDER BY attr_name;")
      expect(quote_attrs).to eq([])
    end
  end
end
