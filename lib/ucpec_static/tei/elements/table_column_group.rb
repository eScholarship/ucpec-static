# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Not a TEI element, but present in the data.
      class TableColumnGroup < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "colgroup"

        uses_html_tag! "colgroup"
      end
    end
  end
end
