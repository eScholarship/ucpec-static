# frozen_string_literal: true

module UCPECStatic
  module TEI
    # An extension of {UCPECStatic::XML::Parsed} for TEI documents.
    class Parsed < UCPECStatic::XML::Parsed
      # @return [Nokogiri::XML::NodeSet]
      def children
        root.children
      end

      # @!attribute [r] nodes_count
      # A count of nodes we care about.
      # @return [Integer]
      def nodes_count
        @nodes_count ||= traverse_header.count + traverse_body.count
      end

      # Traverse the TEI Header nodes.
      #
      # @yield [node]
      # @yieldparam [Nokogiri::XML::Node] node
      # @yieldreturn [void]
      # @return [Enumerator<Nokogiri::XML::Node>]
      def traverse_header
        # :nocov:
        return enum_for(__method__) unless block_given?
        # :nocov:

        root.children.reject(&:text?).each do |child|
          next unless tei_header?(child)

          child.traverse { yield _1 }
        end
      end

      # Traverse the TEI Body nodes.
      #
      # @yield [node]
      # @yieldparam [Nokogiri::XML::Node] node
      # @yieldreturn [void]
      # @return [Enumerator<Nokogiri::XML::Node>]
      def traverse_body
        # :nocov:
        return enum_for(__method__) unless block_given?
        # :nocov:

        root.children.reject(&:text?).each do |child|
          next if tei_header?(child)

          child.traverse { yield _1 }
        end
      end

      private

      # @param [Nokogiri::XML::Node] node
      def tei_header?(node)
        node.name.casecmp?("teiHeader")
      end
    end
  end
end
