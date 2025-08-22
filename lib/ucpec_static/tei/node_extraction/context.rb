# frozen_string_literal: true

module UCPECStatic
  module TEI
    module NodeExtraction
      class Context < Support::FlexibleStruct
        include ReadsNodeStack

        attribute :input, NodeExtraction::ParsedOrNode

        attribute :node, Types::XMLNode

        attribute? :node_attributes, Types::Hash.default(Dry::Core::Constants::EMPTY_HASH)

        attribute :node_klass, Types::Class

        attribute :root, Types::Bool.default(false)

        attribute :skips_children, Types::Bool.default(false)
      end
    end
  end
end
