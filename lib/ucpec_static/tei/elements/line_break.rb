# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-lb.html
      class LineBreak < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "lb"

        uses_html_tag! :br
      end
    end
  end
end
