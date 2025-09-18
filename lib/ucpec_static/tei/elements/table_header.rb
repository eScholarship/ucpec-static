# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Not a TEI element, but present in the data.
      class TableHeader < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "thead"

        uses_html_tag! "thead"
      end
    end
  end
end
