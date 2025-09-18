# frozen_string_literal: true

module UCPECStatic
  module Support
    # @abstract
    #
    # A base class for implementing validators
    class SimpleMonadicValidator
      include UCPECStatic::Support::HasChecks

      # @return [Dry::Monads::Result]
      def call
        run_checks!

        compile_checks
      end
    end
  end
end
