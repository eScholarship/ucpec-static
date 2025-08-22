# frozen_string_literal: true

module UCPECStatic
  module TEI
    module ReadsNodeStack
      include Dry::Effects.Reader(:node_stack, default: Dry::Core::Constants::EMPTY_ARRAY)
    end
  end
end
