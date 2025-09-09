# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-series.html
      class SeriesInformation < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "series"

        uses_html_tag! "span"
      end
    end
  end
end
