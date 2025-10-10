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

          if entity
            transformed_src = transform_image_src(entity)
            html_builder.img(src: transformed_src)
          end
        end

        private

        # @param [String] original_src The original entity value from TEI
        # @return [String] The transformed image source path
        def transform_image_src(original_src)
          base_url = "https://ucpec.s3.us-west-2.amazonaws.com/"
          
          
          "#{base_url}#{original_src}"
        end
      end
    end
  end
end
