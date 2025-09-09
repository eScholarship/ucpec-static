# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-caption.html
      class Caption < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "caption"

        uses_html_tag! "caption"
      end
    end
  end
end
