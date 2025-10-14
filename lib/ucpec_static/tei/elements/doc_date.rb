# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-docDate.html
      class DocDate < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "docDate"

        uses_html_tag! "time"
      end
    end
  end
end
