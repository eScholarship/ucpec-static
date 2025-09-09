# frozen_string_literal: true

module UCPECStatic
  module Operations
    module TEI
      module HTMLConversion
        # Operation for converting TEI XML to HTML.
        # @see UCPECStatic::TEI::HTMLConversion::Converter
        class Convert < UCPECStatic::Support::SimpleServiceOperation
          service_klass UCPECStatic::TEI::HTMLConversion::Converter
        end
      end
    end
  end
end
