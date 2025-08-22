# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Root < UCPECStatic::TEI::Nodes::Element
        memoize def header
          children.detect { _1.kind_of?(DocumentHeader) }
        end

        memoize def text
          children.detect { _1.kind_of?(Text) }
        end
      end
    end
  end
end
