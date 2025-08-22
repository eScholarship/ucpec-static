# frozen_string_literal: true

module UCPECStatic
  module Operations
    module TEI
      class DetermineNodeKlass
        include Dry::Monads[:result, :maybe]

        PATTERNS = {
          /\Adiv\d+\z/i => "Division",
          /\ATEI\.2\z/i => "Root",
        }.freeze

        RENAMED = {
          p: "Paragraph",
          teiHeader: "DocumentHeader",
        }.freeze

        DIRECT = %w[
          back
          body
          figure
          front
          text
        ].index_with(&:classify).freeze

        TAG_TO_KLASS = PATTERNS.merge(RENAMED).merge(DIRECT).transform_keys do |key|
          case key
          when Regexp then key
          else
            /\A#{key}\z/i
          end
        end.transform_values do |val|
          "UCPECStatic::TEI::Elements::#{val}".constantize
        end.freeze

        # @param [Nokogiri::XML::Node] node
        # @return [Dry::Monads::Success(Class)]
        def call(node)
          return Success(UCPECStatic::TEI::Nodes::TextContent) if node.text?

          Maybe(klass_for(node)).to_result.or { Success(UCPECStatic::TEI::Nodes::Element) }
        end

        private

        # @param [Nokogiri::XML::Node] node
        # @return [Class, nil]
        def klass_for(node)
          TAG_TO_KLASS.each do |pattern, klass|
            return klass if pattern.match?(node.name)
          end

          return nil
        end
      end
    end
  end
end
