# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      # A pipeline source that yields (a single) TEI XML file path for processing.
      # @note In the future, this could be extended to process an entire directory
      #   of TEI XML files.
      class Source < UCPECStatic::Pipeline::AbstractSource
        param :tei_path, Types::Path

        def produce_each
          yield tei_path
        end
      end
    end
  end
end
