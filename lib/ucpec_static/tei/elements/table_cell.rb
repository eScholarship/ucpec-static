# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-cell.html
      class TableCell < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "cell"

        # td is not actually a TEI tag, but it is present in the data.
        matches_tei_tag! "td"

        uses_html_tag! "td"
      end
    end
  end
end
