# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      # A PORO that serves as the representation for XML text content.
      #
      # It will be transformed directly into HTML text content.
      class TextContent < Abstract
        match_priority 500

        attribute :content, Types::String

        def render_html_content
          html_builder.text content
        end

        class << self
          def matches_tei_node_type?(node)
            node.text?
          end
        end
      end
    end
  end
end
