# frozen_string_literal: true

module UCPECStatic
  module Support
    # @see UCPECStatic::Support::SimpleMonadicValidator
    module HasChecks
      extend ActiveSupport::Concern

      include Dry::Monads[:list, :validated, :result]

      included do
        extend ActiveModel::Callbacks
        extend Dry::Core::ClassAttributes

        defines :check_map, type: Types::MethodMap

        check_map(Dry::Core::Constants::EMPTY_HASH)

        define_model_callbacks :check
      end

      # @api private
      # @return [void]
      def run_checks!
        run_callbacks :check do
          @checks = run_checks
        end
      end

      # @api private
      # @return [{ Symbol => Dry::Monads::Validated }]
      def run_checks
        self.class.check_map.transform_values do |check_name|
          public_send check_name
        end
      end

      # @api private
      # @return [Dry::Monads::Success<void>]
      # @return [Dry::Monads::Failure(:checks_failed, <String>)]
      def compile_checks
        List::Validated.coerce(@checks.values).traverse.to_result.or do |list|
          Failure[:checks_failed, list.to_a]
        end
      end

      module ClassMethods
        # @param [Symbol] name
        # @yieldreturn [Dry::Monads::Validated]
        def check!(name, &)
          method_name = :"check_#{name}!"

          # :nocov:
          raise "check already exists: #{name}" if check_map.key?(name)
          # :nocov:

          define_method(method_name, &)

          check_map check_map.merge(name => method_name)
        end
      end
    end
  end
end
