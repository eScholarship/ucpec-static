# frozen_string_literal: true

module UCPECStatic
  module TEI
    class Only < UCPECStatic::Pipeline::AbstractTransformer
      # @param [Dry::Monads::Success(UCPECStatic::XML::Parsed)] result
      # @return [Dry::Monads::Success(UCPECStatic::TEI::Parsed)]
      def process(result)
        result.bind do |parsed|
          return nil unless parsed.tei?

          Success parsed.normalize
        end
      end
    end
  end
end
