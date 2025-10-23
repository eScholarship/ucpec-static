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

        def render_html
          return super unless chapter_heading?

          # For chapter headings, wrap content in a self-referencing anchor
          chapter_div = closest_chapter_division
          chapter_id = chapter_div&.node&.[]("id")
          
          if chapter_id.present?
            wrap_with_tag!(html_tag, **compiled_html_attributes) do
              wrap_with_tag!("a", href: "##{chapter_id}", class: "chapter-link") do
                render_html_content!
              end
            end
          else
            super
          end
        end

        private

        def chapter_heading?
          closest_chapter_division.present?
        end

        def closest_chapter_division
          # Only make the direct child heading of a chapter division clickable, not sub-headings
          parent if parent&.kind_of?(Elements::Division) && parent&.xml_attributes&.[]("type") == "chapter"
        end
      end
    end
  end
end
