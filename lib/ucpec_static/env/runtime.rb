# frozen_string_literal: true

module UCPECStatic
  module Env
    class Runtime
      include Dry::Initializer[undefined: false].define -> do
        option :logger, ::UCPECStatic::Types::Logger, default: proc { call_operation!("env.build_logger", verbose: false) }

        option :pwd, ::UCPECStatic::Types::Path, default: proc { Pathname(Dir.pwd) }
      end
    end
  end
end
