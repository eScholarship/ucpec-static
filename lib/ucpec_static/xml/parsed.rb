# frozen_string_literal: true

module UCPECStatic
  module XML
    class Parsed < Support::FlexibleStruct
      include Dry::Core::Equalizer.new(:identifier)
      include Dry::Core::Memoizable
      include UCPECStatic::Support::Successful

      DEFAULT_IDENTIFIER = "input"

      attribute :doc, Types.Instance(::Nokogiri::XML::Document)

      attribute? :identifier, Types::Coercible::String.default(DEFAULT_IDENTIFIER)

      delegate :root, to: :doc
      delegate :name, to: :root, prefix: true, allow_nil: true
      delegate :parsed_xml?, to: :class

      # @return [UCPECStatic::XML::Parsed]
      def normalize
        klass = nil

        if tei? && parsed_xml?
          klass = UCPECStatic::TEI::Parsed
        elsif identifier != normalized_identifier
          klass = self.class
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

      def mets?
        root_name == "mets"
      end

      def tei?
        has_root? &&
          root_name.casecmp?("TEI.2") &&
          doc.xpath("/TEI.2/teiHeader").one? &&
          doc.xpath("/TEI.2/text").one?
      end

      memoize def tei_root_id
        root.attr("id") if tei?
      end

      def tei_root_id?
        tei_root_id.present?
      end

      # @!endgroup

      private

      def normalized_attributes
        { doc:, identifier: normalized_identifier, }
      end

      def normalized_identifier
        if has_default_identifier? && tei_root_id?
          tei_root_id
        else
          identifier
        end
      end

      class << self
        def parsed_xml?
          self == UCPECStatic::XML::Parsed
        end
      end
    end
  end
end
