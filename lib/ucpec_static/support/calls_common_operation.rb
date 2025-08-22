# frozen_string_literal: true

module UCPECStatic
  module Support
    module CallsCommonOperation
      extend ActiveSupport::Concern

      # Call a registered operation with arguments.
      #
      # It will error if the operation does not result in a success.
      #
      # @param [String] name the name of the operation
      # @param [<Object>] args positional arguments to provide to the operation
      # @param [Hash] kwargs keyword arguments to provide to the operation
      # @return [Object]
      def call_operation(name, ...)
        UCPECStatic::Application[name].call(...)
      end

      # Call a registered operation that returns a monadic result.
      #
      # It will error if the operation does not result in a success.
      #
      # @param [String] name the name of the operation
      # @param [<Object>] args arguments to provide to the operation
      # @param [Hash] kwargs keyword arguments to provide to the operation
      # @return [void]
      def call_operation!(...)
        call_operation(...).value!
      end
    end
  end
end
