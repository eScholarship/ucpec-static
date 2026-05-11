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

        option :books, required: false, desc: "Path to books.json metadata cache",
          type: :string, default: nil

        runs_job! UCPECStatic::TEI::HTMLConversion::Job

        # @param [StringIO] sio
        def on_success!(sio)
          write_raw! sio.string
        end

        def perform(tei_path:, books: nil, **)
          run_job(job_klass, tei_path: Pathname.new(tei_path), books_path: books ? Pathname.new(books) : nil) do |m|
            m.success do |result|
              logger.debug("Pipeline complete")
              on_success! result
            end
            m.failure do |*err|
              # :nocov:
              warn Paint["Something went wrong!", :red, :bright]
              warn Paint[err.flatten.join(" ").indent(2), :yellow, :italic]
              # :nocov:
            end
          end
        end
      end
    end
  end
end
