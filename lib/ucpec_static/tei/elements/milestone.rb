# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-milestone.html
      class Milestone < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "milestone"

        uses_html_tag! "span"
      end
    end
  end
end
