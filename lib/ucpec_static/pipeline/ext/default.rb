# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    module Ext
      module Default
        include CapturesPipelineResult
        include ReadsCurrentEnv
        include ReadsCurrentJob
      end
    end
  end
end
