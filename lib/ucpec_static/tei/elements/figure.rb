# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Figure < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "figure"

        uses_html_tag! :figure

        on_xml_attribute!("entity") do |value|
          @entity = value

          @src = config.join_asset_url(value)
        end

        # The value of the `@entity` attribute, if present
        # @return [String, nil]
        attr_reader :entity

        # @return [String, nil]
        attr_reader :src

        def render_html_content
          super

          # :nocov:
          return if src.blank?
          # :nocov:

          html_builder.img(src:)
        end
      end
    end
  end
end
