# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Figure < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "figure"

        uses_html_tag! :figure

        on_xml_attribute!("entity") do |value|
          @entity = value
        end

        # The value of the `@entity` attribute, if present
        # @return [String, nil]
        attr_reader :entity

        def render_html_content
          super

          html_builder.img(src: entity) if entity
        end
      end
    end
  end
end
