# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-listBibl.html
      class CitationList < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "listBibl"

        uses_html_tag! "ul"
      end
    end
  end
end
