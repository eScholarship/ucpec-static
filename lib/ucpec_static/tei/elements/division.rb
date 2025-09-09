# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div.html
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div1.html
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div2.html
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div3.html
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div4.html
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div5.html
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div6.html
      # https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-div7.html
      class Division < UCPECStatic::TEI::Nodes::Element
        DIV_PATTERN = /\Adiv(?<level>\d+)\z/i

        matches_tei_tag! DIV_PATTERN

        matches_tei_tag! "div"
        matches_tei_tag! "div1"
        matches_tei_tag! "div2"
        matches_tei_tag! "div3"
        matches_tei_tag! "div4"
        matches_tei_tag! "div5"
        matches_tei_tag! "div6"
        matches_tei_tag! "div7"

        uses_html_tag! :div

        # @!attribute [r] level
        # @return [Integer]
        memoize def level
          name[DIV_PATTERN, :level].try(:to_i) || 100
        end
      end
    end
  end
end
