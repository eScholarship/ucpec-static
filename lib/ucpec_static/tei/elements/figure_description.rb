# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-figDesc.html
      class FigureDescription < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "figDesc"

        uses_html_tag! "figcaption"
      end
    end
  end
end
