# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-hi.html
      class Highlighted < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "hi"
      end
    end
  end
end
