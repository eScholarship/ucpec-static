# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-ref.html
      class Reference < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "ref"

        uses_html_tag! "a"

        on_xml_attribute!(:id) do |value|
          @ref_id = value
        end

        on_xml_attribute!(:target) do |value|
          @target = value
        end

        on_xml_attribute!(:type) do |value|
          @type = value
          @for_footnote = value.in?(%w[fnoteref noteref secref])
          @is_section_ref = value == "secref"
        end

        after_process_xml_attributes :prepare_footnote_attributes!, if: :valid_footnote?

        # @return [Boolean]
        attr_reader :for_footnote

        alias for_footnote? for_footnote

        # @return [Boolean]
        attr_reader :is_section_ref

        alias is_section_ref? is_section_ref

        # @return [String, nil]
        attr_reader :ref_id

        # @return [String, nil]
        attr_reader :target

        # @return [String]
        attr_reader :type

        def target?
          @target.present?
        end

        def valid_footnote?
          for_footnote? && target?
        end

        private

        # @return [void]
        def prepare_footnote_attributes!
          # For secref: just link to the target section (e.g., "endnotes"), no backlink anchor needed
          unless is_section_ref?
            # For noteref/endnote: use ref's own id for the name (so backlink can find it)
            # For fnoteref/footnote: use target for the name
            anchor_name = ref_id.presence || target

            @html_attributes[:name] = "#{anchor_name}-ref"
          end
          @html_attributes[:href] = "##{target}"
        end
      end
    end
  end
end
