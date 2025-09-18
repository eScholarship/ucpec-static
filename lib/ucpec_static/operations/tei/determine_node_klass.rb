# frozen_string_literal: true

module UCPECStatic
  module Operations
    module TEI
      class DetermineNodeKlass
        using UCPECStatic::XML::Refinements

        extend Dry::Core::Cache

        include Dry::Monads[:result]

        include UCPECStatic::Deps[
          node_klasses: "tei.matchable_node_klasses",
        ]

        # @param [Nokogiri::XML::Node] node
        # @return [Dry::Monads::Success(Class)]
        def call(node)
          Types::XMLNode[node]
        rescue Dry::Types::ConstraintError
          raise TypeError, "must provide an XML node"
        else
          klass = fetch_or_store :derived, node.cache_key do
            klass_for node
          end

          Success klass
        end

        private

        # @param [Nokogiri::XML::Node] node
        # @return [Class, nil]
        def klass_for(node)
          node_klasses.each do |klass|
            return klass if klass.matches_tei_node?(node)
          end

          # :nocov:
          return UCPECStatic::TEI::Nodes::Unknown
          # :nocov:
        end
      end
    end
  end
end
