# frozen_string_literal: true

module UCPECStatic
  module Support
    module HookBased
      # @abstract
      class Actor
        extend ActiveModel::Callbacks
        extend Dry::Core::ClassAttributes
        extend Support::DoFor

        include Dry::Monads[:result, :try]

        include Support::CallsCommonOperation

        # @api private
        TO_RESULT = Support::MonadHelpers::ToResult.new

        private_constant :TO_RESULT

        do_for! :call

        define_model_callbacks :execute

        # @return [Symbol]
        attr_reader :current_hook

        # @abstract
        def call; end

        # @api private
        def inspect
          # :nocov:
          "#<#{self.class}>"
          # :nocov:
        end

        # @api private
        # @yieldreturn [Dry::Monads::Result]
        # @return [Dry::Monads::Result]
        def enforce_monadic
          retval = yield

          TO_RESULT.call(retval)
        end

        class << self
          def inherited(subklass)
            # :nocov:
            super if defined?(super)
            # :nocov:

            subklass.do_for!(:call)
          end

          # @param [Symbol] attr
          # @return [void]
          def simple_reader!(attribute, **options)
            mod = SimpleReader.new(attribute, **options)

            include mod
          end

          def stateful_counter!(attribute, **options)
            mod = StatefulCounter.new(attribute, **options)

            include mod
          end

          def wrapped_hook!(name)
            mod = WrappedHook.new(name)

            include mod
          end
        end
      end
    end
  end
end
