# frozen_string_literal: true

module UCPECStatic
  module XML
    class Parse < UCPECStatic::Pipeline::AbstractTransformer
      # @param [Dry::Monads::Success(Path)] result
      # @return [Dry::Monads::Success(UCPECStatic::XML::Parsed)]
      def process(result)
        result.bind do |input|
          case input
          when Pathname
            input.open("r") do |f|
              parse_xml f, identifier: input.basename.to_s
            end
          when String
            parse_xml input
          else
            # :nocov:
            Failure[:invalid_xml_input, input]
            # :nocov:
          end
        end
      end

      private

      # @param [IO, String] input
      # @return [Dry::Monads::Success(UCPECStatic::XML::Parsed)]
      def parse_xml(input, identifier: "input")
        doc = Nokogiri::XML(input, &:noblanks)

        parsed = UCPECStatic::XML::Parsed.new(doc:, identifier:)

        Success(parsed.normalize)
      end
    end
  end
end
