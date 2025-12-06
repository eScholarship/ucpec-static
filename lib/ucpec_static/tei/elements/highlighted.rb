# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-hi.html
      class Highlighted < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "hi"

        def build_html_tag
          case xml_attributes["rend"]
          when "italic", "italics", "it"
            "i"
          when "bold", "b"
            "b"
          when "underline", "u"
            "u"
          when "sup", "superscript"
            "sup"
          when "sub", "subscript"
            "sub"
          else
            # Default to span for unknown rend values
            "span"
          end
        end
      end
    end
  end
end
