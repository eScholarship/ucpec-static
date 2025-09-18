# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-back.html
      class BackMatter < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "back"

        skip_rendering!
      end
    end
  end
end
