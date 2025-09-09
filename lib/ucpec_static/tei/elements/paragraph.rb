# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-p.html
      class Paragraph < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! ?p

        uses_html_tag! ?p
      end
    end
  end
end
