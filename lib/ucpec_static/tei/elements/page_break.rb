# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-pb.html
      class PageBreak < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "pb"

        on_xml_attribute!("n") do |value|
          @page_number = value
        end

        # The value of the @n attribute (page number), if present
        # @return [String, nil]
        attr_reader :page_number

        def render_html
          if page_number.present?
            # Put the ID on the container so links jump to the page number label
            attrs = compiled_html_attributes.merge(class: "page-break-container")
            html_builder.div(**attrs) do
              html_builder.div(class: "page-number") do
                html_builder.text "#{page_number}"
              end
              html_builder.hr(**compiled_html_attributes)
            end
          else
            # Fallback to just hr if no page number
            html_builder.hr(**compiled_html_attributes)
          end
        end
      end
    end
  end
end
