# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Body < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "body"

        uses_html_tag! :section
      end
    end
  end
end
