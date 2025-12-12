# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-docDate.html
      class DocDate < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "docDate"

        uses_html_tag! "span"

        def render_html
          year = node.text.strip

          # Wrap with copyright text
          wrap_with_tag!(html_tag, **compiled_html_attributes) do
            html_builder.text "© #{year} The Regents of the University of California"
          end
        end
      end
    end
  end
end
