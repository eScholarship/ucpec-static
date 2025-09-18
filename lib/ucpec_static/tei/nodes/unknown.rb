# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      # A fallback for XML nodes we don't know how to process, things like :document, :attr, etc.
      #
      # Should not normally occur and will be ignored when rendering if encountered.
      class Unknown < Abstract
        match_priority(-1000)

        skip_rendering!

        class << self
          def matches_tei_node_type?(node)
            !(node.element? || node.comment? || node.text?)
          end
        end
      end
    end
  end
end
