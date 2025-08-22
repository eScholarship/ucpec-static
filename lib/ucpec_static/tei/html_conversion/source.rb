# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      class Source < UCPECStatic::Pipeline::AbstractSource
        param :tei_path, Types::Path

        def produce_each
          yield tei_path
        end
      end
    end
  end
end
