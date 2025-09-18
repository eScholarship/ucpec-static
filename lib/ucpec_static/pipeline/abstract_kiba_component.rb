# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    # @abstract
    class AbstractKibaComponent
      extend ActiveModel::Callbacks
      extend Dry::Core::ClassAttributes
      extend Dry::Initializer

      TO_RESULT = Support::MonadHelpers::ToResult.new

      include Dry::Monads[:result]

      include UCPECStatic::Pipeline::Ext::Default
      include UCPECStatic::Support::CallsCommonOperation

      define_model_callbacks :initialize, only: %i[after]

      def initialize(...)
        run_callbacks :initialize do
          super
        end
      end
    end
  end
end
