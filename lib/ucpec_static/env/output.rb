# frozen_string_literal: true

module UCPECStatic
  module Env
    class Output
      include Dry::Initializer[undefined: false].define -> do
        option :pwd, ::UCPECStatic::Types::Path, default: proc { Pathname(Dir.pwd) }
      end
    end
  end
end
