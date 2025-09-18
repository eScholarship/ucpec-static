# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Supplanted by {Reference} in P5.
      #
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-ref.html
      # @see https://www.tei-c.org/Vault/P4/migrate.html
      class ExtendedReference < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "xref"

        uses_html_tag! ?a
      end
    end
  end
end
