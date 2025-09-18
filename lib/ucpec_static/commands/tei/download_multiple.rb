# frozen_string_literal: true

module UCPECStatic
  module Commands
    module TEI
      # A helper command to download multiple TEI XML documents
      # from a base URL and a list of files to download.
      #
      # @see UCPECStatic::Downloading::Job
      class DownloadMultiple < UCPECStatic::AbstractCommand
        desc <<~TEXT
        Download multiple documents using a base URL and a newline-separated list
        of files to copy from that origin.
        TEXT

        argument :base_url, required: true, desc: "The base url to download from",
          type: :string

        argument :list_path, required: true, desc: "A text file listing one file per line to download",
          type: :string

        option :output_path, required: false, desc: "A path to a relative directory to put the files.",
          type: :string, default: "./tei", aliases: %w[-o]

        runs_job! UCPECStatic::Downloading::Job
      end
    end
  end
end
