# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      # A PORO that serves as the abstract base class for all TEI XML **elements**.
      # XML Elements are the nodes that we need to process most, so there is
      # additional logic here.
      #
      # @abstract
      # @see UCPECStatic::TEI::Nodes::FallbackElement
      class Element < Abstract
        define_model_callbacks :process_xml_attributes

        matchable false

        uses_render_order! :render_children

        defines :html_tag, type: Types::String.optional

        defines :xml_attribute_handlers, type: UCPECStatic::Types::XMLAttributeHandlers

        xml_attribute_handlers({ "id" => :copy, "rend" => :html_class }.freeze)

        defines :default_xml_attribute_action, type: UCPECStatic::Types::XMLAttributeAction

        default_xml_attribute_action :data_attribute

        html_tag nil

        attribute :children, NodeList

        attribute :name, Types::String

        attribute? :content, Types::String.optional

        before_prepare_html :process_xml_attributes!

        # @return [ActiveSupport::HashWithIndifferentAccess]
        attr_reader :html_attributes

        # @return [ActiveSupport::HashWithIndifferentAccess]
        attr_reader :html_data_attributes

        # @return [<String>]
        attr_reader :html_classes

        # @return [Boolean]
        attr_reader :xml_attributes_processed

        alias xml_attributes_processed? xml_attributes_processed

        def initialize(...)
          super

          @xml_attributes_processed = false
          @html_data_attributes = build_html_data_attributes
          @html_attributes = {}.with_indifferent_access
          @html_classes = []
        end

        # @!attribute [r] compiled_html_attributes
        # @return [Hash{Symbol => Object}]
        memoize def compiled_html_attributes
          compile_html_attributes
        end

        # @!attribute [r] html_tag
        # @return [String, nil]
        memoize def html_tag
          build_html_tag
        end

        # @!attribute [r] static_html_tag
        # @return [String, nil]
        def static_html_tag
          self.class.html_tag
        end

        # @api private
        # @return [void]
        def render_children!
          # :nocov:
          return if skip_render_children?
          # :nocov:

          run_callbacks :render_children do
            children.each do |child|
              child.to_html
            end
          end
        end

        def render_html
          return super if html_tag.blank?

          wrap_with_tag!(html_tag, **compiled_html_attributes) do
            super
          end
        end

        # @api private
        # @return [void]
        def process_xml_attributes!
          # :nocov:
          return if xml_attributes_processed?
          # :nocov:

          run_callbacks :process_xml_attributes do
            xml_attributes.each do |attr_name, attr_value|
              handler = xml_attribute_handler_for(attr_name)

              case handler
              when :copy
                html_attributes[attr_name.to_sym] = attr_value
              when :data_attribute
                html_data_attributes[attr_name.to_sym] = attr_value
              when :html_class
                html_classes << attr_value
              when :skip
                # :nocov:
                next
                # :nocov:
              when Proc
                instance_exec(attr_value, &handler)
              end
            end
          end

          @xml_attributes_processed = true
        end

        private

        def build_html_classes
          html_classes.compact_blank.uniq
        end

        def build_html_data_attributes
          {}.tap do |data|
            data[:tei_tag] = name if static_html_tag.present? && name != static_html_tag
          end.with_indifferent_access
        end

        # @abstract
        # @return [String, nil]
        def build_html_tag
          static_html_tag
        end

        # @return [Hash{Symbol => Object}]
        def compile_html_attributes
          process_xml_attributes!

          built = html_attributes.dup.tap do |attrs|
            html_data_attributes.each do |key, value|
              full_key = "data_#{key}".dasherize

              attrs[full_key.to_sym] = value
            end

            attrs[:class] = compile_html_classes

            attrs[:id] = node["id"].presence
          end

          Types::AttributeMap[built.compact]
        end

        # @return [String, nil]
        def compile_html_classes
          build_html_classes.join(" ").presence
        end

        def xml_attribute_handler_for(attr_name)
          self.class.xml_attribute_handlers[attr_name.to_s] ||
            self.class.default_xml_attribute_action
        end

        class << self
          def matches_tei_node_type?(node)
            node.element?
          end

          # A DSL method that registers a handler for a specific XML attribute.
          #
          # @example Copy the value of the `@id` attribute to the HTML attributes as `id`
          #   on_xml_attribute!("id", :copy)
          # @example Copy the value of the `@type` attribute to a `data-type` HTML data attribute
          #   on_xml_attribute!("type", :data_attribute)
          # @example Add the value of the `@rend` attribute to the HTML class list
          #   on_xml_attribute!("rend", :html_class)
          # @example Skip processing the `@xml:lang` attribute entirely
          #   on_xml_attribute!("xml:lang", :skip)
          # @example Custom processing of the `@custom` attribute
          #   on_xml_attribute!("custom") do |value|
          #     @html_attributes[:customattr] = "custom-#{value}"
          #     @html_classes << "custom-#{value}"
          #   end
          # @param [#to_s] name
          # @param [:copy, :data_attribute, :html_class, :skip, nil] action
          # @return [void]
          def on_xml_attribute!(name, action = nil, &block)
            # :nocov:
            raise ArgumentError, "Must provide either an action or a block" if action.nil? && block.nil?
            raise ArgumentError, "Cannot provide both an action and a block" if action && block
            # :nocov:

            new_handlers = xml_attribute_handlers.merge(name.to_s => action || block).freeze

            xml_attribute_handlers new_handlers
          end

          # @param [#to_s] tag
          # @return [void]
          def uses_html_tag!(tag)
            html_tag tag.to_s
          end
        end
      end
    end
  end
end
