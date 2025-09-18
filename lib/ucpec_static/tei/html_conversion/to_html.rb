# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      # A pipeline transformer that converts TEI XML to HTML.
      #
      # @see UCPECStatic::Operations::TEI::HTMLConversion::Convert
      # @see UCPECStatic::Operations::TEI::HTMLConversion::Converter
      class ToHTML < UCPECStatic::Pipeline::AbstractTransformer
        # @param [Dry::Monads::Success(UCPECStatic::TEI::Nodes::Abstract)] result
        #   The result of the previous step in the pipeline.
        # @return [Dry::Monads::Success(String)]
        def process(result)
          result.bind do |node|
            call_operation("tei.html_conversion.convert", node)
          end
        end
      end
    end
  end
end
