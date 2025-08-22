# frozen_string_literal: true

module UCPECStatic
  module Support
    module HookBased
      module Types
        include Dry.Types

        Attribute = Coercible::Symbol.constrained(format: /\A[a-z]\w*[a-z]\z/).freeze

        HookName = Coercible::Symbol.constrained(format: /\A[a-z]\w*[a-z]\z/).freeze
      end
    end
  end
end
