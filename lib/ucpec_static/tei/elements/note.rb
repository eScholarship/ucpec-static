# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-note.html
      class Note < UCPECStatic::TEI::Nodes::Element
        include UCPECStatic::TEI::Nodes::CapturedInFootnotes

        before_render_children :add_anchor!, if: :counts_as_footnote?

        matches_tei_tag! "note"

        uses_html_tag! "aside"

        on_xml_attribute!(:type) do |value|
          @counts_as_footnote = value == "footnote"
        end

        on_xml_attribute!(:id) do |value|
          @target = value
        end

        # @return [String, nil]
        attr_reader :target

        private

        # @return [void]
        def add_anchor!
          # :nocov:
          return if target.blank?
          # :nocov:

          html_builder.nav(class: "footnote--nav") do
            html_builder.a(nil, name: target, class: "footnote--anchor")
            html_builder.a("Back", href: "##{target}-ref", class: "footnote--backlink", title: "Return to previous location in text")
          end
        end
      end
    end
  end
end
