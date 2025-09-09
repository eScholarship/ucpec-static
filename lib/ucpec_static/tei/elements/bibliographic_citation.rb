# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-bibl.html
      class BibliographicCitation < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "bibl"

        uses_html_tag! "cite"
      end
    end
  end
end
