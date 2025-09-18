# frozen_string_literal: true

module UCPECStatic
  module XML
    module Refinements
      refine Nokogiri::XML::Node do
        delegate :name, to: :parent, allow_nil: true, prefix: true
        delegate :element?, to: :previous_sibling, allow_nil: true, prefix: true
        delegate :element?, to: :next_sibling, allow_nil: true, prefix: true

        def between_elements?
          previous_sibling_element? && next_sibling_element?
        end

        # @return [String]
        def cache_key
          case node_type
          in Nokogiri::XML::Node::TEXT_NODE
            "xml/text"
          in Nokogiri::XML::Node::COMMENT_NODE
            "xml/comment"
          in Nokogiri::XML::Node::ELEMENT_NODE
            "xml/element/#{node_name}"
          else
            "xml/unknown/#{node_type}"
          end
        end

        def skippable_text_node?
          return false unless text?

          # Text nodes with content are never skipped.
          return false if inner_text.present?

          # Leaf text nodes containing whitespace that are between elements are never skipped
          return false if between_elements?

          # Otherwise skip this text node
          return true
        end
      end
    end
  end
end
