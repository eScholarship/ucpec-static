# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Root < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "TEI"

        matches_tei_tag! "TEI.2"

        uses_html_tag! :main

        memoize def header
          find_first_descendant { _1.kind_of?(DocumentHeader) }
        end

        memoize def text
          find_first_descendant { _1.kind_of?(Text) }
        end
      end
    end
  end
end
