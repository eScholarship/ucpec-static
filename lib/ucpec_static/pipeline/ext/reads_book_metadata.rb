# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    module Ext
      module ReadsBookMetadata
        include Dry::Effects.Reader(:book_metadata)

        # @return [Hash, nil]
        def book_metadata
          super { nil }
        end
      end
    end
  end
end
