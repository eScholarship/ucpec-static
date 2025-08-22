# frozen_string_literal: true

module UCPECStatic
  module TEI
    module NodeExtraction
      class Source < UCPECStatic::Pipeline::AbstractSource
        using UCPECStatic::XML::Refinements

        include State

        def produce_each
          node.children.each do |child|
            next if child.skippable_text_node?

            next unless child.text? || child.element?

            yield child
          end
        end
      end
    end
  end
end
