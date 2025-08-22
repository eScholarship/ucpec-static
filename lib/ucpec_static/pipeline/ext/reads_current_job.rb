# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    module Ext
      module ReadsCurrentJob
        include Dry::Effects.Reader(:current_job)
      end
    end
  end
end
