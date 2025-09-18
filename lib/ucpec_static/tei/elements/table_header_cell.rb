# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Not a TEI element, but present in the data.
      class TableHeaderCell < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "th"

        uses_html_tag! "th"
      end
    end
  end
end
