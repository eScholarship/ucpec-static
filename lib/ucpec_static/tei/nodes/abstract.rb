# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      class Abstract < Support::WritableStruct
        include Dry::Core::Equalizer.new(:node_id)
        include Dry::Core::Memoizable

        NodeList = Types::Array.of(self).default(Dry::Core::Constants::EMPTY_ARRAY)

        Parsed = Types.Instance(::UCPECStatic::TEI::Parsed)

        attribute :input, NodeExtraction::ParsedOrNode

        attribute :node, Types::XMLNode

        # @return [UCPECStatic::TEI::Nodes::Abstract]
        attr_accessor :parent

        def node_id
          node.object_id
        end

        # @return [UCPECStatic::TEI::Parsed]
        def parsed
          return input if input.kind_of?(UCPECStatic::TEI::Parsed)

          parent&.parsed
        end
      end
    end
  end
end
