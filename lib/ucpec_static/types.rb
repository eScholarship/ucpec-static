# frozen_string_literal: true

module UCPECStatic
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    AttributeMap = Hash.map(Coercible::Symbol, Any)

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

    Pattern = Instance(Regexp)

    Patterns = Array.of(Pattern)

    RenderOrder = Types::Symbol.default(:after_content).enum(:none, :before_content, :after_content)

    TagPattern = Pattern | String

    TagPatterns = Array.of(TagPattern)

    URL = String | Instance(::URI)

    XMLAttributeAction = Types::Symbol.enum(:copy, :data_attribute, :html_class, :skip)
    XMLAttributeCallable = Instance(Proc)
    XMLAttributeHandler = XMLAttributeAction | XMLAttributeCallable
    XMLAttributeHandlers = Hash.map(Coercible::String, XMLAttributeHandler)

    XMLNode = Instance(Nokogiri::XML::Node)

    XMLNodes = Array.of(XMLNode).default(Dry::Core::Constants::EMPTY_ARRAY)
  end
end
