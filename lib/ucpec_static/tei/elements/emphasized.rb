# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-emph.html
      class Emphasized < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "emph"

        uses_html_tag! "em"
      end
    end
  end
end
