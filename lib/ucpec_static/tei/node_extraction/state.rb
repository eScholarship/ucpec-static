# frozen_string_literal: true

module UCPECStatic
  module TEI
    module NodeExtraction
      module State
        include UCPECStatic::TEI::ReadsNodeStack

        include Dry::Effects.Reader(:context)

        delegate :input,
          :node,
          :node_attributes,
          :node_klass,
          :root,
          :skips_children,
          to: :context

        alias root? root

        alias skips_children? skips_children
      end
    end
  end
end
