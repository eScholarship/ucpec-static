# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-front.html
      class FrontMatter < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "front"

        uses_html_tag! "header"

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

            # Render all other (non-TitlePage) children outside the styled div
            children.each do |child|
              next if child.kind_of?(TitlePage)
              child.to_html
            end
          end
        end

        private

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
