# frozen_string_literal: true

module UCPECStatic
  module Support
    # A concern that signifies the class it's included on
    # should be treated as a monadic success when asked.
    module Successful
      include Dry::Monads[:result]

      def to_monad
        Success(self)
      end
    end
  end
end
