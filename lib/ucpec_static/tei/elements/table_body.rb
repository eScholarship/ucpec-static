# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Not a TEI element, but present in the data.
      class TableBody < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "tbody"

        uses_html_tag! "tbody"
      end
    end
  end
end
