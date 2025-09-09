# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-list.html
      class List < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "list"

        uses_html_tag! "ul"
      end
    end
  end
end
