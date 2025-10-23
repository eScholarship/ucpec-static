# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-front.html
      class FrontMatter < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "front"

        uses_html_tag! "header"

        # Only render titlePage children, skip everything else in front matter
        def render_children!
          return if skip_render_children?

          run_callbacks :render_children do
            children.each do |child|
              next unless child.kind_of?(TitlePage)
              
              child.to_html
            end
          end
        end
      end
    end
  end
end
