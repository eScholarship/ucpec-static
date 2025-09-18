# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-quote.html
      class Quotation < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "quote"

        uses_html_tag! "blockquote"
      end
    end
  end
end
