# frozen_string_literal: true

module UCPECStatic
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    BroadcastLogger = Instance(UCPECStatic::Support::BroadcastLogger)

    Logger = BroadcastLogger

    MethodMap = Hash.map(Symbol, Symbol)

    Path = Instance(::Pathname).constructor do |input|
      case input
      when ::Pathname then input
      when ::String then Pathname(input)
      else
        input
      end
    end

    URL = String | Instance(::URI)

    XMLNode = Instance(Nokogiri::XML::Node)

    XMLNodes = Array.of(XMLNode).default(Dry::Core::Constants::EMPTY_ARRAY)
  end
end
