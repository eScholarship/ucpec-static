# frozen_string_literal: true

module UCPECStatic
  module Downloading
    class Destination < UCPECStatic::Pipeline::AbstractDestination
      # @param [Dry::Monads::Success(UCPECStatic::Downloading::Result)] monad
      def write(monad)
        # no-op
      end
    end
  end
end
