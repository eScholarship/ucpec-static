# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      # A pipeline job that converts TEI XML to HTML.
      #
      # @see UCPECStatic::Commands::TEI::ConvertToHTML
      # @see UCPECStatic::TEI::HTMLConversion::Source
      # @see UCPECStatic::XML::Parse
      # @see UCPECStatic::TEI::Only
      # @see UCPECStatic::TEI::ExtractNodes
      # @see UCPECStatic::TEI::HTMLConversion::ToHTML
      # @see UCPECStatic::TEI::HTMLConversion::Destination
      class Job < UCPECStatic::Pipeline::AbstractJob
        include Dry::Effects::Handler.Reader(:book_metadata)

        option :tei_path, Types::Path
        option :books_path, Types::Path.optional, default: proc {}

        build_job! do |job|
          source UCPECStatic::TEI::HTMLConversion::Source, job.tei_path

          transform UCPECStatic::XML::Parse

          transform UCPECStatic::TEI::Only, raise_on_non_tei: true

          transform UCPECStatic::TEI::ExtractNodes

          transform UCPECStatic::TEI::HTMLConversion::ToHTML

          destination UCPECStatic::TEI::HTMLConversion::Destination
        end

        private

        # Provide the book metadata hash (keyed from books.json) for the current TEI file,
        # or nil if no books path was given or the ARK is not found.
        def provide_book_metadata!
          ark = tei_path.basename(".xml").to_s
          metadata = load_books_index[ark]

          with_book_metadata(metadata) { yield }
        end

        def load_books_index
          return {} if books_path.nil? || !books_path.exist?

          @books_index ||= JSON.parse(books_path.read)
            .each_with_object({}) { |b, h| h[b["ark"]] = b }
        end

        around_kiba :provide_book_metadata!
      end
    end
  end
end
