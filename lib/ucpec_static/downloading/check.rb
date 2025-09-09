# frozen_string_literal: true

module UCPECStatic
  module Downloading
    class Check < UCPECStatic::Pipeline::AbstractTransformer
      include State

      # @param [Dry::Monads::Success(Hash)] monad
      # @return [nil] we yield downloadables in the {#close} method
      def process(monad)
        monad.bind do |tuple|
          tuple => { destination:, }

          if destination.exist?
            self.file_count -= 1

            return nil
          end

          Success tuple
        end
      end
    end
  end
end
