# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Text < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "text"

        memoize def body
          # :nocov:
          children.detect { _1.kind_of?(Body) }
          # :nocov:
        end
      end
    end
  end
end
