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
          # Make all headings that are direct children of divisions clickable
          parent_div = parent if parent.kind_of?(Elements::Division)
          div_id = parent_div&.node&.[]("id")

          if div_id.present?
            # Wrap heading content in a self-referencing anchor link
            wrap_with_tag!(html_tag, **compiled_html_attributes) do
              wrap_with_tag!("a", href: "##{div_id}", class: "heading-link") do
                render_html_content!
              end
            end
          else
            super
          end
        end
      end
    end
  end
end
