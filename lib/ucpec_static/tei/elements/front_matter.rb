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
            render_title_section!
            render_dedications!
            render_preferred_citation!
            render_table_of_contents! if has_chapters?
            render_other_front_matter!
          end
        end

        # Check if there are any chapters to display in ToC
        def has_chapters?
          chapters.any?
        end

        private

        # Render book cover and title page in styled container
        # @return [void]
        def render_title_section!
          wrap_with_tag!("div", **compiled_html_attributes) do
            render_book_cover!
            render_title_pages!
          end
        end

        # Render title page children
        # @return [void]
        def render_title_pages!
          children.each do |child|
            next unless child.kind_of?(TitlePage)
            child.to_html
          end
        end

        # Render dedication elements
        # @return [void]
        def render_dedications!
          children.each do |child|
            next unless dedication?(child)
            child.to_html
          end
        end

        # Render all other front matter content
        # @return [void]
        def render_other_front_matter!
          children.each do |child|
            next if child.kind_of?(TitlePage)
            next if dedication?(child)
            child.to_html
          end
        end

        # Check if a child is a dedication
        # @param [UCPECStatic::TEI::Nodes::Abstract] child
        # @return [Boolean]
        def dedication?(child)
          child.kind_of?(Division) && child.xml_attributes["type"] == "dedication"
        end

        # Collect all ToC-worthy sections from front matter, body, and back matter
        # @return [void]
        def collect_chapters!
          meta = book_metadata
          @chapters = meta&.dig("toc")&.map { |entry| { id: entry["id"], title: entry["label"] } } || []
        end

        # Render the preferred citation block if book metadata is available
        # @return [void]
        def render_preferred_citation!
          meta = book_metadata
          return if meta.nil?

          author    = meta["author_citation"].to_s
          title     = meta["title"].to_s
          place     = meta["place"].to_s
          publisher = meta["publisher"].to_s
          year      = meta["year"].to_s
          raw_date  = meta["date_issued"].to_s
          date_str  = raw_date.start_with?("c") ? "#{raw_date} #{year}" : year

          wrap_with_tag!("aside", class: "preferred-citation") do
            wrap_with_tag!("p") do
              wrap_with_tag!("strong") { html_builder.text "Preferred Citation:" }
              html_builder.text " #{author} " unless author.empty?
              wrap_with_tag!("cite") { html_builder.text title } unless title.empty?
              html_builder.text ". " unless title.empty?
              location = [place, publisher].reject(&:empty?).join(":  ")
              html_builder.text "#{location},  #{date_str}." unless location.empty?
            end
          end
        end

        # Render the table of contents navigation
        # @return [void]
        def render_table_of_contents!
          wrap_with_tag!("details", class: "table-of-contents") do
            wrap_with_tag!("summary", class: "toc-title") do
              html_builder.text "Table of Contents"
            end

            wrap_with_tag!("ul", class: "toc-list") do
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
