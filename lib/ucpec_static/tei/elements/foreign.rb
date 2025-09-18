# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-foreign.html
      class Foreign < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "foreign"

        uses_html_tag! "i"
      end
    end
  end
end
