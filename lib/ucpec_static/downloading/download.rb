# frozen_string_literal: true

module UCPECStatic
  module Downloading
    class Download < UCPECStatic::Pipeline::AbstractTransformer
      include HasProgressBar
      include State

      # Sanity check to make sure we don't download anything too excessive.
      MAX_SIZE = 15.megabytes

      # @param [Dry::Monads::Success(Hash)] monad
      # @return [Dry::Monads::Success(UCPECStatic::Downloading::Result)]
      # @return [nil] to drop the row after an error
      def process(monad)
        monad.bind do |tuple|
          download!(**tuple)
        end
      end

      private

      # @param [URL] url
      # @param [Pathname] destination
      # @return [Dry::Monads::Success(UCPECStatic::Downloading::Result)]
      # @return [nil]
      def download!(url:, destination:)
        content_length_proc = ->(content_length) do
          update_total_size!(destination, content_length)

          refresh_bar_total!
        end

        progress_proc = ->(progress) do
          bar.progress += progress
        rescue ProgressBar::InvalidProgressError
          # race condition, intentionally left blank
        end

        Down.download(url, max_size: MAX_SIZE, destination:, content_length_proc:, progress_proc:)
      rescue Down::Error => e
        bar.log "[#{url}] problem downloading (#{e.class}): #{e.message}"

        # Drop the row for further processing
        return nil
      else
        Success UCPECStatic::Downloading::Result.new(url:, destination:)
      end

      def progress_bar_title
        "Downloading TEI Documents..."
      end

      def progress_bar_total
        [total_size, calculate_total_size, AVERAGE_FILE_SIZE * 1000].detect(&:nonzero?)
      end
    end
  end
end
