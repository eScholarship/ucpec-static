# frozen_string_literal: true

module UCPECStatic
  module TEI
    # A transformer that only allows TEI documents to pass through.
    class Only < UCPECStatic::Pipeline::AbstractTransformer
      option :raise_on_non_tei, Types::Bool, default: proc { false }

      alias raise_on_non_tei? raise_on_non_tei

      # @param [Dry::Monads::Success(UCPECStatic::XML::Parsed)] result
      # @return [Dry::Monads::Success(UCPECStatic::TEI::Parsed)]
      def process(result)
        result.bind do |parsed|
          unless parsed.tei?
            if raise_on_non_tei?
              raise UCPECStatic::TEI::InvalidDocumentError.new(identifier: parsed.identifier)
            else
              return nil
            end
          end

          Success parsed.normalize
        end
      end
    end
  end
end
