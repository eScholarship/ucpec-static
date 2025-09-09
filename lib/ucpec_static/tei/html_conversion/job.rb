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
        option :tei_path, Types::Path

        build_job! do |job|
          source UCPECStatic::TEI::HTMLConversion::Source, job.tei_path

          transform UCPECStatic::XML::Parse

          transform UCPECStatic::TEI::Only, raise_on_non_tei: true

          transform UCPECStatic::TEI::ExtractNodes

          transform UCPECStatic::TEI::HTMLConversion::ToHTML

          destination UCPECStatic::TEI::HTMLConversion::Destination
        end
      end
    end
  end
end
