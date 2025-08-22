# frozen_string_literal: true

module UCPECStatic
  module Operations
    module Pipeline
      class Run
        include UCPECStatic::Pipeline::Ext::ReadsCurrentEnv
        include Dry::Monads[:result, :do]

        # @param [Class(UCPECStatic::Pipeline::AbstractJob)] klass
        # @return [void]
        def call(klass, ...)
          job = klass.new(...)

          job.call
        end
      end
    end
  end
end
