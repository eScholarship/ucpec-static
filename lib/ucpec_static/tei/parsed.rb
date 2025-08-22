# frozen_string_literal: true

module UCPECStatic
  module TEI
    class Parsed < UCPECStatic::XML::Parsed
      def children
        root.children
      end

      def root_stats
        # :nocov:
        root.children.reject(&:text?).map(&:name).tally
        # :nocov:
      end

      def traverse_header
        # :nocov:
        return enum_for(__method__) unless block_given?
        # :nocov:

        root.children.reject(&:text?).each do |child|
          next unless tei_header?(child)

          child.traverse { yield _1 }
        end
      end

      def traverse_body
        # :nocov:
        return enum_for(__method__) unless block_given?
        # :nocov:

        root.children.reject(&:text?).each do |child|
          next if tei_header?(child)

          child.traverse { yield _1 }
        end
      end

      def tei_header?(node)
        node.name.casecmp?("teiHeader")
      end
    end
  end
end
