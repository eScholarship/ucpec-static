# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-item.html
      class ListItem < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "item"

        uses_html_tag! "li"
      end
    end
  end
end
