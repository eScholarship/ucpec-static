# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-ref.html
      class Reference < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "ref"

        uses_html_tag! "a"

        on_xml_attribute!(:target) do |value|
          @target = value
        end

        on_xml_attribute!(:type) do |value|
          @type = value
          @for_footnote = value == "fnoteref"
        end

        after_process_xml_attributes :prepare_footnote_attributes!, if: :valid_footnote?

        # @return [Boolean]
        attr_reader :for_footnote

        alias for_footnote? for_footnote

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
          @html_attributes[:name] = "#{target}-ref"
          @html_attributes[:href] = "##{target}"
        end
      end
    end
  end
end
