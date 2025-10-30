# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-titlePage.html
      class TitlePage < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "titlePage"

        uses_html_tag! "div"

        def render_html
          wrap_with_tag!(html_tag, **compiled_html_attributes) do
            render_combined_title!
            render_other_children!
          end
        end

        private

        # concatenates main and subtitle into a single h1 tag
        def render_combined_title!
          main_title = find_title_part("main")
          subtitle = find_title_part("subtitle") || find_title_part("sub")

          return unless main_title

          wrap_with_tag!("h1") do
            html_builder.text main_title.node.inner_text
            if subtitle
              html_builder.text ": "
              html_builder.text subtitle.node.inner_text
            end
          end
        end

        def render_other_children!
          children.each do |child|
            next if child.kind_of?(TitlePart)
            child.to_html
          end
        end

        def find_title_part(type)
          children.find { |child| child.kind_of?(TitlePart) && child.xml_attributes["type"] == type }
        end
      end
    end
  end
end
