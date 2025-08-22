# frozen_string_literal: true

module UCPECStatic
  module TEI
    module NodeExtraction
      class Job < UCPECStatic::Pipeline::AbstractJob
        using UCPECStatic::XML::Refinements

        param :input, NodeExtraction::ParsedOrNode

        simple_reader! :context

        simple_reader! :input, skip_attr_reader: true

        # @!attribute [r] node
        # @return [Nokogiri::XML::Node]
        simple_reader! :node

        # @!attribute [r] node
        # @return [Hash]
        simple_reader! :node_attributes

        # @!attribute [r] node_klass
        # @return [Class]
        simple_reader! :node_klass

        # @!attribute [r] node_stack
        # @return [<Nokogiri::XML::Node>]
        simple_reader! :node_stack

        # @!attribute [r] root
        # @return [Boolean]
        simple_reader! :root

        alias root? root

        # @return [Boolean]
        simple_reader! :skips_children

        alias skips_children? skips_children

        build_job! do |job|
          source UCPECStatic::TEI::NodeExtraction::Source

          transform UCPECStatic::TEI::ExtractNodes

          destination UCPECStatic::TEI::NodeExtraction::Destination
        end

        around_kiba :provide_context!

        def set_up
          @root = input.kind_of?(UCPECStatic::TEI::Parsed)

          @node = root? ? input.root : input

          @node_attributes = { input:, node:, }

          @node_klass = call_operation!("tei.determine_node_klass", node)

          @skips_children = node.text? || node.children.reject(&:skippable_text_node?).blank?

          yield extract_attributes!

          @context = build_context

          super
        end

        wrapped_hook! def extract_attributes
          yield extract_element_attributes! if node.element?

          yield extract_text_attributes! if node.text?

          super
        end

        wrapped_hook! def extract_element_attributes
          node_attributes[:name] = node.name

          super
        end

        wrapped_hook! def extract_text_attributes
          node_attributes[:content] = node.content

          super
        end

        private

        def build_context
          Context.new(
            input:,
            node:,
            node_attributes:,
            node_klass:,
            root:,
            skips_children:,
          )
        end
      end
    end
  end
end
