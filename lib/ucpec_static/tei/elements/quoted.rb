# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # An inline quotation. Compare with {Quotation}.
      #
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-q.html
      class Quoted < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! ?q

        uses_html_tag! :q
      end
    end
  end
end
