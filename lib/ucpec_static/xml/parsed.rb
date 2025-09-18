# frozen_string_literal: true

module UCPECStatic
  module XML
    # A parsed XML document.
    #
    # For future-proofing, it supports METS XML Documents,
    # but it is primarily intended for TEI XML Documents.
    #
    # @see UCPECStatic::TEI::Parsed
    class Parsed < Support::FlexibleStruct
      include Dry::Core::Equalizer.new(:identifier)
      include Dry::Core::Memoizable
      include UCPECStatic::Support::Successful

      # If no #{identifier} is provided, use this default.
      DEFAULT_IDENTIFIER = "input"

      # @!attribute [r] doc
      # @return [::Nokogiri::XML::Document]
      attribute :doc, Types.Instance(::Nokogiri::XML::Document)

      # @!attribute [r] identifier
      # @return [String]
      attribute? :identifier, Types::Coercible::String.default(DEFAULT_IDENTIFIER)

      # @!attribute [r] root
      # @return [Nokogiri::XML::Node]
      delegate :root, to: :doc

      # @!attribute [r] root_name
      # @return [String, nil]
      delegate :name, to: :root, prefix: true, allow_nil: true

      delegate :parsed_xml?, to: :class

      # Normalize the parsed XML document, transforming it into a more specific
      # subclass if possible.
      # @return [UCPECStatic::XML::Parsed]
      def normalize
        klass = nil

        if tei? && parsed_xml?
          klass = UCPECStatic::TEI::Parsed
        elsif identifier != normalized_identifier
          # :nocov:
          # Future-proofing for METS/other XML types.
          klass = self.class
          # :nocov:
        end

        return klass.new(**normalized_attributes) if klass.present?

        return self
      end

      # @!group Introspection

      def has_default_identifier?
        identifier == DEFAULT_IDENTIFIER
      end

      def has_root?
        root_name.present?
      end

      # Detect METS XML Documents.
      def mets?
        root_name == "mets"
      end

      # Detect TEI XML Documents.
      #
      # @see UCPECStatic::TEI::Parsed
      def tei?
        has_root? &&
          root_name.casecmp?("TEI.2") &&
          doc.xpath("/TEI.2/teiHeader").one? &&
          doc.xpath("/TEI.2/text").one?
      end

      # @!attribute [r] tei_root_id
      # @return [String, nil]
      memoize def tei_root_id
        # :nocov:
        root.attr("id") if tei?
        # :nocov:
      end

      # @see #tei_root_id
      def tei_root_id?
        tei_root_id.present?
      end

      alias has_tei_root_id? tei_root_id?

      # @!endgroup

      private

      def normalized_attributes
        { doc:, identifier: normalized_identifier, }
      end

      def normalized_identifier
        # :nocov:
        if has_default_identifier? && tei_root_id?
          tei_root_id
        else
          identifier
        end
        # :nocov:
      end

      class << self
        def parsed_xml?
          self == UCPECStatic::XML::Parsed
        end
      end
    end
  end
end
