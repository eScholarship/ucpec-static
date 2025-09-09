# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    module Ext
      module ReadsCurrentEnv
        include Dry::Core::Cache
        include Dry::Effects.Reader(:current_env)

        delegate :logger, to: :env

        # @return [UCPECStatic::Env::Runtime]
        def env
          current_env { default_env }
        end

        def default_env
          # :nocov:
          fetch_or_store __method__ do
            UCPECStatic::Application["env.build"].().value!
          end
          # :nocov:
        end
      end
    end
  end
end
