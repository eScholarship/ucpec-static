# frozen_string_literal: true

module UCPECStatic
  module Commands
    module TEI
      # The main command for this application: convert a TEI XML file to HTML.
      #
      # @see UCPECStatic::TEI::HTMLConversion::Job
      class ToHTML < UCPECStatic::AbstractCommand
        desc "Convert a single TEI document to HTML"

        argument :tei_path, required: true, desc: "The path to the TEI XML file to process",
          type: :string

        runs_job! UCPECStatic::TEI::HTMLConversion::Job

        # @param [StringIO] sio
        def on_success!(sio)
          write_raw! sio.string
        end
      end
    end
  end
end
