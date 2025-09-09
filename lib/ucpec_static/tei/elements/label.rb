# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-label.html
      class Label < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "label"

        uses_html_tag! "label"
      end
    end
  end
end
