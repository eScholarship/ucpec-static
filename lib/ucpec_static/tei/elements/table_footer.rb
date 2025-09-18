# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Not a TEI element, but present in the data.
      class TableFooter < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "tfoot"

        uses_html_tag! "tfoot"
      end
    end
  end
end
