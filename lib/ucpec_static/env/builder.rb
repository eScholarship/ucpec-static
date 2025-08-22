# frozen_string_literal: true

module UCPECStatic
  module Env
    class Builder < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        option :pwd, ::UCPECStatic::Types::Path, default: proc { Pathname(Dir.pwd) }

        option :verbose, Types::Bool, default: proc { false }
      end

      # @return [UCPECStatic::Env::Runtime]
      attr_reader :env

      # @return [UCPECStatic::Support::BroadcastLogger]
      attr_reader :logger

      def call
        run_callbacks :execute do
          yield prepare!

          yield build!
        end

        Success env
      end

      wrapped_hook! def prepare
        @logger = yield call_operation("env.build_logger", verbose:)

        super
      end

      wrapped_hook! def build
        @env = Runtime.new(logger:, pwd:)

        super
      end
    end
  end
end
