# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-note.html
      class Note < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "note"

        uses_html_tag! "aside"
      end
    end
  end
end
