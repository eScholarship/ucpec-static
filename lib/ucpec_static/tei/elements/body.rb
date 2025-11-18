# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Body < UCPECStatic::TEI::Nodes::Element
        before_prepare_html :collect_chapters!

        around_render_children :render_with_toc!

        matches_tei_tag! "body"

        uses_html_tag! :section

        # @return [Array<Hash>]
        attr_reader :chapters

        # Check if there are any chapters to display in ToC
        def has_chapters?
          chapters.any?
        end

        private

        # Collect all div elements with type="chapter" (div1, div2, etc.)
        # @return [void]
        def collect_chapters!
          @chapters = []

          # Traverse all descendants to find any division element with type="chapter"
          traverse do |node|
            next unless node.kind_of?(Elements::Division)
            next unless node.xml_attributes["type"] == "chapter"

            chapter_id = node.xml_attributes["id"]
            next if chapter_id.blank?

            # Find the heading within this chapter
            heading = node.find_first_descendant { |child| child.kind_of?(Elements::Heading) }
            next unless heading

            # Extract the heading text
            heading_text = extract_heading_text(heading)

            @chapters << {
              id: chapter_id,
              title: heading_text,
              level: node.level
            }
          end
        end

        # Extract text content from a heading node
        # @param [UCPECStatic::TEI::Nodes::Element] heading
        # @return [String]
        def extract_heading_text(heading)
          heading.node.text.strip
        end

        # Render table of contents before children
        # @return [void]
        def render_with_toc!
          render_table_of_contents! if has_chapters?
          yield
        end

        # Render the table of contents navigation
        # @return [void]
        def render_table_of_contents!
          wrap_with_tag!("nav", class: "table-of-contents") do
            wrap_with_tag!("h1", class: "toc-title") do
              html_builder.text "Table of Contents"
            end

            wrap_with_tag!("ol", class: "toc-list") do
              chapters.each do |chapter|
                wrap_with_tag!("li", class: "toc-item") do
                  wrap_with_tag!("a", href: "##{chapter[:id]}", class: "toc-link") do
                    html_builder.text chapter[:title]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
