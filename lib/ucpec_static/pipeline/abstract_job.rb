# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    # A top-level Kiba job
    class AbstractJob < Support::HookBased::Actor
      extend ActiveModel::Callbacks
      extend Dry::Initializer

      include Dry::Effects::Handler.Reader(:current_job)
      include Dry::Effects::Handler.State(:pipeline_result)

      include UCPECStatic::Pipeline::Ext::ReadsCurrentEnv
      include UCPECStatic::Support::HasChecks

      # @return [Object]
      attr_reader :pipeline_result

      def call
        run_callbacks :execute do
          yield set_up!

          yield validate!

          yield kiba!
        end

        Success pipeline_result
      end

      wrapped_hook! :set_up

      wrapped_hook! def validate
        run_checks!

        yield compile_checks

        super
      end

      wrapped_hook! def kiba
        job = build_job

        Kiba.run(job)

        super
      end

      around_kiba :provide_current_job!

      around_kiba :capture_pipeline_result!

      # @!group Integration Methods

      # @abstract
      # @note This should call `parse_with_kiba` instead of `Kiba.parse`.
      # @return [Kiba::Control]
      def build_job
        # :nocov:
        parse_with_kiba
        # :nocov:
      end

      # @!endgroup

      private

      # @return [void]
      def capture_pipeline_result!
        @pipeline_result, result = with_pipeline_result nil do
          yield
        end

        return result
      end

      # A thin wrapper around `Kiba.parse` that sets up our environment
      # to be aware of the application runtime and anything else we need
      # to set up for a given job and its component pieces.
      #
      # @yield [UCPECStatic::Pipeline::AbstractJob] job
      # @yieldreturn [void]
      # @return [Kiba::Control]
      def parse_with_kiba(&)
        job = self

        Kiba.parse do
          extend UCPECStatic::Pipeline::Ext::Default

          # :nocov:
          instance_exec(job, &) if block_given?
          # :nocov:
        end
      end

      # @return [void]
      def provide_current_job!
        with_current_job self do
          yield
        end
      end

      class << self
        # @return [void]
        def build_job!(&)
          define_method(:build_job) do
            parse_with_kiba(&)
          end
        end
      end
    end
  end
end
