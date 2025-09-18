# frozen_string_literal: true

module UCPECStatic
  module Commands
    module TEI
      # A debugging command to list TEI tags that this application knows how to parse.
      class ListKnownTags < UCPECStatic::AbstractCommand
        desc <<~TEXT
        List tags that this application knows how to parse.
        TEXT

        def perform(*)
          known_tags = UCPECStatic::Application["tei.known_tags"]

          known_tags.each { write! _1 }
        end
      end
    end
  end
end
