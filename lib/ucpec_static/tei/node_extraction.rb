# frozen_string_literal: true

module UCPECStatic
  module TEI
    module NodeExtraction
      ParsedOrNode = Types.Instance(UCPECStatic::TEI::Parsed) | Types::XMLNode
    end
  end
end
