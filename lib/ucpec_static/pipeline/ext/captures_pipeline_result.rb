# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    module Ext
      module CapturesPipelineResult
        include Dry::Effects.State(:pipeline_result)
      end
    end
  end
end
