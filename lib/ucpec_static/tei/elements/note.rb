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
          # Only capture inline footnotes, or endnotes with corresp (noteref-style)
          # Endnotes without corresp (secref-style) render in place
          @counts_as_footnote = value == "footnote"
          @is_endnote = value == "endnote"
        end

        on_xml_attribute!(:id) do |value|
          @target = value
        end

        on_xml_attribute!(:corresp) do |value|
          @corresp = value
        end

        # @return [String, nil]
        attr_reader :target

        # @return [String, nil]
        attr_reader :corresp

        # @return [String, nil]
        attr_reader :type

        # @return [Boolean]
        attr_reader :is_endnote

        alias is_endnote? is_endnote

        # Capture noteref-style endnotes (with corresp) but not secref-style (without corresp)
        def counts_as_footnote?
          super || (is_endnote? && corresp.present?)
        end

        # Should add anchor/backlink for notes that will be captured (have backlink target)
        # Secref-style endnotes (without corresp) render in place without backlinks
        def should_add_anchor?
          counts_as_footnote? && has_backlink_target?
        end

        # Check if this note has a backlink target (corresp for endnotes, or is a footnote)
        def has_backlink_target?
          corresp.present? || type == "footnote"
        end

        private

        # @return [void]
        def add_anchor!
          # :nocov:
          return if target.blank?
          # :nocov:

          # For noteref/endnote with corresp: corresp points to the ref's id
          # For fnoteref/footnote: use target (same as note's id)
          ref_id = corresp.presence || target

          html_builder.nav(class: "footnote--nav") do
            html_builder.a(nil, name: target, class: "footnote--anchor")
            html_builder.a("Back", href: "##{ref_id}-ref", class: "footnote--backlink", title: "Return to previous location in text")
          end
        end
      end
    end
  end
end
