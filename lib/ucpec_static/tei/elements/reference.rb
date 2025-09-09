# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-ref.html
      class Reference < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "ref"

        uses_html_tag! "a"
      end
    end
  end
end
