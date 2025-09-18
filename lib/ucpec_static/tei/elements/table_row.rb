# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-row.html
      class TableRow < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "row"

        # tr is not actually a TEI tag, but it is present in the data.
        matches_tei_tag! "tr"

        uses_html_tag! "tr"
      end
    end
  end
end
