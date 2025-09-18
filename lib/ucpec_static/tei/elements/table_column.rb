# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Not a TEI element, but present in the data.
      class TableColumn < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "col"

        uses_html_tag! "col"
      end
    end
  end
end
