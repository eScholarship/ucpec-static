# frozen_string_literal: true

module UCPECStatic
  module TEI
    class ExtractNodes < UCPECStatic::Pipeline::AbstractTransformer
      include ReadsNodeStack

      # @param [Dry::Monads::Success(UCPECStatic::TEI::Parsed), Dry::Monads::Success(Nokogiri::XML::Node)] result
      # @return [Dry::Monads::Success(UCPECStatic::TEI::Nodes::Abstract)]
      def process(result)
        result.bind do |input|
          UCPECStatic::TEI::NodeExtraction::Job.new(input).().or { nil }
        end
      end
    end
  end
end
