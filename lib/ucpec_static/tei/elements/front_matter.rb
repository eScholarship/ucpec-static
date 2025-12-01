# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-front.html
      class FrontMatter < UCPECStatic::TEI::Nodes::Element
        before_prepare_html :collect_chapters!

        matches_tei_tag! "front"

        uses_html_tag! "header"

        # @return [Array<Hash>]
        attr_reader :chapters

        # Book cover + title page in one div, rest outside
        def render_html
          wrap_with_tag!(html_tag) do
            # Wrap book cover and title page together with front matter styling
            wrap_with_tag!("div", **compiled_html_attributes) do
              render_book_cover!
              
              # Render only TitlePage children
              children.each do |child|
                next unless child.kind_of?(TitlePage)
                child.to_html
              end
            end

            # Render dedication elements
            children.each do |child|
              next unless child.kind_of?(Division) && child.xml_attributes["type"] == "dedication"
              child.to_html
            end

            # Render table of contents after title page and dedication
            render_table_of_contents! if has_chapters?

            # Render all other (non-TitlePage, non-dedication) children
            children.each do |child|
              next if child.kind_of?(TitlePage)
              next if child.kind_of?(Division) && child.xml_attributes["type"] == "dedication"
              child.to_html
            end
          end
        end

        # Check if there are any chapters to display in ToC
        def has_chapters?
          chapters.any?
        end

        private

        # Collect all chapters from the body element
        # @return [void]
        def collect_chapters!
          @chapters = []

          # Find the root element by traversing ancestors
          root_element = closest { |node| node.kind_of?(Root) }
          return unless root_element

          # Find the body element from the root
          body_element = root_element.find_first_descendant { |node| node.kind_of?(Body) }
          return unless body_element

          # Traverse body to find all division elements with type="chapter"
          body_element.traverse do |node|
            next unless node.kind_of?(Division)
            next unless node.xml_attributes["type"] == "chapter"

            chapter_id = node.xml_attributes["id"]
            next if chapter_id.blank?

            # Find the heading within this chapter
            heading = node.find_first_descendant { |child| child.kind_of?(Heading) }
            next unless heading

            # Extract the heading text
            heading_text = heading.node.text.strip

            @chapters << {
              id: chapter_id,
              title: heading_text,
              level: node.level
            }
          end
        end

        # Render the table of contents navigation
        # @return [void]
        def render_table_of_contents!
          wrap_with_tag!("nav", class: "table-of-contents") do
            wrap_with_tag!("h2", class: "toc-title") do
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

        # @return [void]
        def render_book_cover!
          cover_url = book_cover_url
          return if cover_url.blank?

          wrap_with_tag!("div", class: "book-cover") do
            wrap_with_tag!("img", src: cover_url, alt: "Book Cover")
          end
        end

        # @return [String, nil]
        def book_cover_url
          file_id = tei_root_file_id
          return nil if file_id.blank?

          cover_filename = "#{file_id}_cover.jpg"
          config.join_asset_url(cover_filename)
        end

        # @return [String, nil]
        def tei_root_file_id
          parsed&.tei_root_id
        end
      end
    end
  end
end
