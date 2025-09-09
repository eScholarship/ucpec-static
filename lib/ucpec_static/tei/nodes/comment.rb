# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      # An XML comment node.
      #
      # It will be transformed into an HTML comment node.
      class Comment < Abstract
        match_priority 500

        attribute :content, Types::String

        def render_html_content
          # :nocov:
          html_builder.comment content
          # :nocov:
        end

        class << self
          def matches_tei_node_type?(node)
            node.comment?
          end
        end
      end
    end
  end
end
