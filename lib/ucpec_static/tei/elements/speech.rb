# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-sp.html
      class Speech < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "sp"

        uses_html_tag! "div"
      end
    end
  end
end
