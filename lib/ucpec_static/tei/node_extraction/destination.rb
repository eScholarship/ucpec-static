# frozen_string_literal: true

module UCPECStatic
  module TEI
    module NodeExtraction
      class Destination < UCPECStatic::Pipeline::AbstractDestination
        include State

        # @return [Array]
        attr_reader :children

        def initialize
          @children = []
        end

        def write(child)
          @children << child.value_or(nil)

          @children.compact!
        end

        def close
          attrs = finalize_attributes

          tei_node = node_klass.new(**attrs)

          children.each do |child|
            child.parent = tei_node
          end

          self.pipeline_result = tei_node
        end

        private

        def finalize_attributes
          return node_attributes if skips_children

          node_attributes.merge(children:)
        end
      end
    end
  end
end
