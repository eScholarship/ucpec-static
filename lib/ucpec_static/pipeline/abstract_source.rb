# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    class AbstractSource < AbstractKibaComponent
      define_model_callbacks :each

      def each
        produce_each do |item|
          run_callbacks :each do
            yield TO_RESULT.(item)
          end
        end
      end

      # @abstract
      # @yield [Object] item
      # @return [void]
      def produce_each; end
    end
  end
end
