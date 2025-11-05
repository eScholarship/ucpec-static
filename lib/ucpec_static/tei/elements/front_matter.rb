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
            render_book_cover!

            children.each do |child|
              next unless child.kind_of?(TitlePage)

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
          root_element = closest { _1.kind_of?(Root) }
          root_element&.xml_attributes&.[]("id")
        end
      end
    end
  end
end
