# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      # A PORO that serves as the abstract base class for all TEI XML node representations.
      # @abstract
      # @see UCPECStatic::TEI::Nodes::Comment
      # @see UCPECStatic::TEI::Nodes::Element
      # @see UCPECStatic::TEI::Nodes::TextContent
      # @see UCPECStatic::TEI::Nodes::Unknown
      class Abstract < Support::WritableStruct
        extend ActiveModel::Callbacks
        extend Dry::Core::ClassAttributes

        include UCPECStatic::HasConfig
        include Dry::Core::Constants
        include Dry::Core::Equalizer.new(:node_id)
        include Dry::Core::Memoizable
        include Dry::Effects.Reader(:html_builder)

        NodeList = Types::Array.of(self).default(Dry::Core::Constants::EMPTY_ARRAY)

        Parsed = Types.Instance(::UCPECStatic::TEI::Parsed)

        define_model_callbacks :prepare_html, :html_rendering, :html_content

        defines :match_priority, type: Types::Integer

        defines :matchable, type: Types::Bool

        defines :rendering_skipped, type: Types::Bool

        defines :tei_tag_patterns, type: Types::TagPatterns

        match_priority 0

        matchable false

        rendering_skipped false

        tei_tag_patterns EMPTY_ARRAY

        attribute :input, NodeExtraction::ParsedOrNode

        # @!attribute [r] node
        # The underlying Nokogiri XML node that this object wraps.
        # @return [Nokogiri::XML::Node]
        attribute :node, Types::XMLNode

        # A back-reference to the parent node.
        # Used for traversal and introspection.
        # @return [UCPECStatic::TEI::Nodes::Abstract, nil]
        attr_accessor :parent

        # @api private
        # @note Used for equality checks and hashing.
        # @return [Integer]
        def node_id
          node.object_id
        end

        # @!attribute [r] parsed
        # The parsed TEI document that this node is part of.
        # It is provided mainly for introspection and is not
        # guaranteed to be present.
        # @return [UCPECStatic::TEI::Parsed]
        def parsed
          # :nocov:
          return input if input.kind_of?(UCPECStatic::TEI::Parsed)

          parent&.parsed
          # :nocov:
        end

        def rendering_skipped?
          self.class.rendering_skipped
        end

        # @!attribute [r] xml_attributes
        # XML Attributes are extracted from the original node into a hash
        # for ease of processing and introspection.
        # @return [ActiveSupport::HashWithIndifferentAccess]
        memoize def xml_attributes
          extract_xml_attributes
        end

        # @!group Hooks

        # @api private
        # @abstract
        # @return [void]
        def render_html
          render_html_content!
        end

        # @api private
        # @abstract
        # @return [void]
        def render_html_content; end

        # @!endgroup

        # @return [void]
        def to_html
          return if rendering_skipped?

          run_callbacks :prepare_html do
            prepare_html!
          end

          run_callbacks :html_rendering do
            render_html!
          end
        end

        # @!group HTML Helpers

        # @return [void]
        def wrap_with_tag!(tag_name, **attrs, &)
          # We have to do this because things like "p" will not generate tags.
          safe_tag = "#{tag_name}_"

          html_builder.__send__(safe_tag, **attrs, &)
        end

        # @!endgroup

        # @!group Traversal

        memoize def ancestors
          return EMPTY_ARRAY if parent.nil?

          [parent, *parent.ancestors]
        end

        def closest(&)
          self_and_ancestors.detect(&)
        end

        def find_first_descendant(&)
          traverse.detect(&)
        end

        def closest_division
          closest { _1 != self && _1.kind_of?(Elements::Division) }
        end

        def self_and_ancestors
          [self, *ancestors]
        end

        def traverse(&)
          return enum_for(__method__) unless block_given?

          yield self

          return unless respond_to?(:children)

          children.each do |child|
            child.traverse(&)
          end
        end

        # @!endgroup

        private

        # @return [ActiveSupport::HashWithIndifferentAccess]
        def extract_xml_attributes
          node.attributes.values.to_h { [_1.name, _1.value] }.with_indifferent_access
        end

        # @!group Hook Wrappers

        def render_html!
          render_html
        end

        # @return [void]
        def render_html_content!
          run_callbacks :html_content do
            render_html_content
          end
        end

        # @!endgroup

        # @abstract
        # @return [void]
        def prepare_html!; end

        class << self
          def element_klass?
            self < UCPECStatic::TEI::Nodes::Element
          end

          # @return [<Class>]
          def matchable_node_klasses
            # :nocov:
            return UCPECStatic::TEI::Nodes::Abstract.matchable_node_klasses if self != UCPECStatic::TEI::Nodes::Abstract
            # :nocov:

            descendants.select(&:matchable).sort_by { -_1.match_priority }.freeze
          end

          # @abstract
          # @param [Nokogiri::XML::Node] node
          def matches_tei_node?(node)
            matches_tei_node_type?(node) && matches_tei_tag?(node)
          end

          # @abstract
          # @param [Nokogiri::XML::Node] node
          def matches_tei_node_type?(node); end

          # @param [Nokogiri::XML::Node, String] node_or_name
          def matches_tei_tag?(node_or_name)
            case node_or_name
            in Nokogiri::XML::Node then matches_tei_tag_name?(node_or_name.name)
            in String then matches_tei_tag_name?(node_or_name)
            end
          end

          # @param [String] name
          def matches_tei_tag_name?(name)
            return true if tei_tag_patterns.blank?

            tei_tag_patterns.any? do |pattern|
              tei_tag_pattern_matches?(pattern, name)
            end
          end

          # @param [Regexp, String, Symbol] tag_pattern
          # @return [void]
          def matches_tei_tag!(tag_pattern)
            tag_pattern = tag_pattern.to_s.freeze if tag_pattern.kind_of?(Symbol)

            new_patterns = tei_tag_patterns | [tag_pattern]

            tei_tag_patterns new_patterns.freeze
          end

          # @return [void]
          def skip_rendering!
            rendering_skipped true
          end

          # @param [Symbol] base
          # @return [void]
          def uses_render_order!(base)
            hook = RenderOrderHook.new(base)

            include hook
          end

          # @api private
          def inherited(subclass)
            super

            # Ensure that subclasses are marked matchable when the current node isn't
            subclass.matchable true
          end

          private

          # @param [Regexp, String] pattern
          # @param [String] name
          def tei_tag_pattern_matches?(pattern, name)
            case pattern
            when String
              pattern.casecmp?(name)
            else
              name.match?(pattern)
            end
          end
        end
      end
    end
  end
end
