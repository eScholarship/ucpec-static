# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      # A pipeline destination that collects the final HTML output into a StringIO.
      # @see UCPECStatic::TEI::HTMLConversion::ToHTML
      class Destination < UCPECStatic::Pipeline::AbstractDestination
        def initialize
          self.pipeline_result = StringIO.new
        end

        # @param [Dry::Monads::Result(String)] HTML from the `ToHTML` transformer
        # @return [void]
        def write(row)
          row.bind do |output|
            pipeline_result.puts output
          end
        end
      end
    end
  end
end
