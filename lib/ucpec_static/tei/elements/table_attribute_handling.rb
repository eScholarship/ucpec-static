# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # Common logic for handling common table and
      # table-related element attributes
      module TableAttributeHandling
        extend ActiveSupport::Concern

        included do
          on_xml_attribute!("align", :copy)
          on_xml_attribute!("colspan", :copy)
          on_xml_attribute!("rowspan", :copy)
          on_xml_attribute!("valign", :copy)
          on_xml_attribute!("width", :copy)
        end
      end
    end
  end
end
