# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-titlePart.html
      class TitlePart < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "titlePart"

        def build_html_tag
          case xml_attributes["type"]
          when "main"
            "h1"
          when "sub", "subtitle"
            "h2"
          else
            "h3"
          end
        end
      end
    end
  end
end
