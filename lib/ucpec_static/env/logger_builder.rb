# frozen_string_literal: true

module UCPECStatic
  module Env
    class LoggerBuilder < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        option :verbose, Types::Bool, default: proc { false }
      end

      # @return [Logger]
      attr_reader :base_logger

      # @return [UCPECStatic::Support::BroadcastLogger]
      attr_reader :logger

      def call
        run_callbacks :execute do
          yield configure!
        end

        Success logger
      end

      wrapped_hook! def configure
        base_target = verbose ? $stderr : File::NULL

        @base_logger = build_tagged_logger_for base_target

        @logger = UCPECStatic::Support::BroadcastLogger.new(@base_logger)

        super
      end

      private

      # @param [Object] target
      # @return [ActiveSupport::TaggedLogging]
      def build_tagged_logger_for(target)
        logger = ::Logger.new(target)

        ActiveSupport::TaggedLogging.new(logger)
      end
    end
  end
end
