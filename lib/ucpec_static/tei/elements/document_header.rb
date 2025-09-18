# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class DocumentHeader < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "teiHeader"

        skip_rendering!
      end
    end
  end
end
