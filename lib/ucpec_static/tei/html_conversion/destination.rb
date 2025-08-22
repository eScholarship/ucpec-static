# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      class Destination < UCPECStatic::Pipeline::AbstractDestination
        def initialize
          self.pipeline_result = []
        end

        def write(row)
          pipeline_result << row
        end
      end
    end
  end
end
