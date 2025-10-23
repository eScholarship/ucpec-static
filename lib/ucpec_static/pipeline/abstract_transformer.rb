# frozen_string_literal: true

module UCPECStatic
  module Pipeline
    class AbstractTransformer < AbstractKibaComponent
      # @param [Object] row
      # @return [void]
      def process(row); end

      module HasProgressBar
        extend ActiveSupport::Concern

        # @!attribute [r] bar
        # @return [ProgressBar]
        def bar
          @bar ||= build_bar
        end

        def close
          bar.try(:finish)

          # :nocov:
          super if defined?(super)
          # :nocov:
        end

        private

        def progress_bar_options
          {
            format: progress_bar_format,
            progress_mark: " ",
            remainder_mark: "\u{FF65}",
            output: $stderr,
            projector: {
              type: "smoothed",
              strength: 0.1
            },
            title: progress_bar_title,
            total: progress_bar_total,
          }
        end

        def progress_bar_format
          "%a %b\u{15E7}%i %p%% #{progress_bar_rate} %t :: %e"
        end

        def progress_bar_rate
          "(%R/sec)"
        end

        # @abstract
        # @return [String, nil]
        def progress_bar_title; end

        # @abstract
        # @return [Integer, nil]
        def progress_bar_total; end

        # @return [void]
        def refresh_bar_total!
          bar.total = [bar.progress, progress_bar_total].max
        end

        # @return [void]
        def build_bar
          ProgressBar.create(**progress_bar_options)
        end
      end
    end
  end
end
