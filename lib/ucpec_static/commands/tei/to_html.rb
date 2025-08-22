# frozen_string_literal: true

module UCPECStatic
  module Commands
    module TEI
      class ToHTML < UCPECStatic::AbstractCommand
        desc "Convert a single TEI document to HTML"

        argument :tei_path, required: true, desc: "The path to the TEI XML file to process",
          type: :string

        runs_job! UCPECStatic::TEI::HTMLConversion::Job
      end
    end
  end
end
