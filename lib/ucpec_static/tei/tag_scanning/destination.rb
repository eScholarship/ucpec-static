# frozen_string_literal: true

module UCPECStatic
  module TEI
    module TagScanning
      # Not much is done with the destination in this pipeline at present.
      class Destination < UCPECStatic::Pipeline::AbstractDestination
        def initialize
          self.pipeline_result = []
        end

        # @param [Dry::Monads::Success(UCPECStatic::TEI::Parsed)] row
        #   the result from the `TraverseTags` transformer
        # @return [void]
        def write(row)
          pipeline_result << row
        end
      end
    end
  end
end
