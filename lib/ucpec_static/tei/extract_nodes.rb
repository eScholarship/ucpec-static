# frozen_string_literal: true

module UCPECStatic
  module TEI
    # A transformer that extracts TEI nodes into their corresponding Ruby objects.
    #
    # This transformer can handle either a full {UCPECStatic::TEI::Parsed} document or a single
    # Nokogiri XML Node. In either case, it produces a {UCPECStatic::TEI::Nodes::Abstract node}
    # that can be rendered as HTML.
    #
    # @see UCPECStatic::TEI::NodeExtraction::Job
    class ExtractNodes < UCPECStatic::Pipeline::AbstractTransformer
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
