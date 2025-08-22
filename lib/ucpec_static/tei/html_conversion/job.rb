# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      class Job < UCPECStatic::Pipeline::AbstractJob
        option :tei_path, Types::Path

        build_job! do |job|
          source UCPECStatic::TEI::HTMLConversion::Source, job.tei_path

          transform UCPECStatic::XML::Parse

          transform UCPECStatic::TEI::ExtractNodes

          destination UCPECStatic::TEI::HTMLConversion::Destination
        end
      end
    end
  end
end
