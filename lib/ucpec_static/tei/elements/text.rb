# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Text < UCPECStatic::TEI::Nodes::Element
        memoize def body
          children.detect { _1.kind_of?(Body) }
        end
      end
    end
  end
end
