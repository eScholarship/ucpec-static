# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-title.html
      class Title < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "title"

        uses_html_tag! "cite"
      end
    end
  end
end
