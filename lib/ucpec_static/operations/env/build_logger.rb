# frozen_string_literal: true

module UCPECStatic
  module Operations
    module Env
      class BuildLogger < UCPECStatic::Support::SimpleServiceOperation
        service_klass UCPECStatic::Env::LoggerBuilder
      end
    end
  end
end
