# frozen_string_literal: true

module UCPECStatic
  module Operations
    module Env
      class Build < UCPECStatic::Support::SimpleServiceOperation
        service_klass UCPECStatic::Env::Builder
      end
    end
  end
end
