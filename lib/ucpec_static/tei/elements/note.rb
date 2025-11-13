# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-note.html
      class Note < UCPECStatic::TEI::Nodes::Element
        include UCPECStatic::TEI::Nodes::CapturedInFootnotes

        before_render_children :add_anchor!, if: :should_add_anchor?

        matches_tei_tag! "note"

        uses_html_tag! "aside"

        on_xml_attribute!(:type) do |value|
          @type = value
          @is_endnote = value == "endnote"
        end

        on_xml_attribute!(:id) do |value|
          @target = value
        end

        on_xml_attribute!(:corresp) do |value|
          @corresp = value
        end

        after_process_xml_attributes :set_counts_as_footnote!
        after_process_xml_attributes :add_acknowledgement_class!

        # @return [String, nil]
        attr_reader :target

        # @return [String, nil]
        attr_reader :corresp

        # @return [String, nil]
        attr_reader :type

        # @return [Boolean]
        attr_reader :is_endnote

        alias is_endnote? is_endnote

        # Check if this note is inside a back element
        def in_back_matter?
          ancestors.any? { |ancestor| ancestor.is_a?(BackMatter) }
        end

        # Capture inline notes that are actually referenced
        # Endnotes always render in place (never captured)

        private

        # Set counts_as_footnote based on type and corresp
        # Capture footnotes that should be moved to the bottom
        def set_counts_as_footnote!
          # type="footnote" - always capture (inline footnotes)
          # type="note" with corresp - capture (referenced notes)
          # type="note" without corresp - render in place (chapter acknowledgements)
          # type="endnote" - never capture, always render in place
          if type == "footnote"
            @counts_as_footnote = true
          elsif type == "note"
            @counts_as_footnote = corresp.present?
          else
            @counts_as_footnote = false
          end
        end

        # Add a CSS class for acknowledgement notes (unreferenced notes)
        def add_acknowledgement_class!
          if type == "note" && corresp.blank?
            html_classes << "acknowledgement-note"
          end
        end

        # Add anchor for all notes with an id (for bidirectional linking)
        def should_add_anchor?
          target.present?
        end

        # Add backlink if note has corresp OR is a captured footnote
        # Endnotes in back matter without corresp (secref-style) won't have backlinks
        def has_backlink?
          corresp.present? || (counts_as_footnote? && target.present?)
        end

        # @return [void]
        def add_anchor!
          # :nocov:
          return if target.blank?
          # :nocov:

          html_builder.nav(class: "footnote--nav") do
            html_builder.a(nil, name: target, class: "footnote--anchor")

            # Only add backlink if corresp exists (bidirectional linking)
            if has_backlink?
              ref_id = corresp.presence || target
              html_builder.a("Back", href: "##{ref_id}-ref", class: "footnote--backlink", title: "Return to previous location in text")
            end
          end
        end
      end
    end
  end
end
