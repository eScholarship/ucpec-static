# frozen_string_literal: true

module UCPECStatic
  module TEI
    module NodeExtraction
      # A type that is either a {UCPECStatic::TEI::Parsed} or a raw Nokogiri XML Node.
      ParsedOrNode = Types.Instance(UCPECStatic::TEI::Parsed) | Types::XMLNode
    end
  end
end
