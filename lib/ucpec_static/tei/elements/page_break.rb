# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-pb.html
      class PageBreak < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "pb"

        # Page breaks have no HTML equivalent
        skip_rendering!
      end
    end
  end
end
