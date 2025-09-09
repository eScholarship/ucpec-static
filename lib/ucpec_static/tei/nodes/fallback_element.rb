# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      # This element serves as a catch-all for nodes that
      # are not currently represented and either need to be
      # added, or don't have any content that needs to be
      # handled specially.
      class FallbackElement < UCPECStatic::TEI::Nodes::Element
        match_priority(-500)
      end
    end
  end
end
