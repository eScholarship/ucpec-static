# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-head.html
      class Heading < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "head"

        def build_html_tag
          div = closest_division

          case div&.level
          when 1...6
            "h#{div.level}"
          else
            "h6"
          end
        end
      end
    end
  end
end
