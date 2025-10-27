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
          # Capture both footnotes and endnotes to move them to the footer
          @counts_as_footnote = value.in?(%w[footnote endnote])
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

        # Should add anchor for both footnotes and endnotes
        def should_add_anchor?
          counts_as_footnote? || is_endnote?
        end

        private

        # @return [void]
        def add_anchor!
          # :nocov:
          return if target.blank?
          # :nocov:

          # For noteref/endnote: corresp points to the ref's id, so we use that for the backlink
          # For fnoteref/footnote: no corresp, so we use target for the backlink
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
