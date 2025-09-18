# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-table.html
      class Table < UCPECStatic::TEI::Nodes::Element
        include TableAttributeHandling

        matches_tei_tag! "table"

        uses_html_tag! "table"

        on_xml_attribute!("cellpadding", :copy)
        on_xml_attribute!("cellspacing", :copy)
        on_xml_attribute!("frame", :copy)
        on_xml_attribute!("rules", :copy)
      end
    end
  end
end
