# frozen_string_literal: true

module UCPECStatic
  module Commands
    module TEI
      # A helper command to scan TEI tags in a directory and generate
      # a SQLite3 database with statistics. This is used to review what
      # tags need to be handled by this application.
      #
      # @see UCPECStatic::TEI::TagScanning::Job
      class ScanTags < UCPECStatic::AbstractCommand
        desc <<~TEXT
        Scan TEI tags in a directory and generate a SQLite3 database
        with statistics. This is used to review what tags need to be
        handled by this application.
        TEXT

        option :directory, required: false, desc: "The path to a directory with TEI XML files. Non-TEI will be ignored.",
          type: :string, default: "./tei", aliases: %w[-d]

        option :db_path, required: false, desc: "The path to write the SQLite3 database file.",
          type: :string, default: "./tags.sqlite3", aliases: %w[-o]

        option :fresh, required: false, desc: "If the database file already exists, delete it first.",
          type: :boolean, default: false

        runs_job! UCPECStatic::TEI::TagScanning::Job
      end
    end
  end
end
