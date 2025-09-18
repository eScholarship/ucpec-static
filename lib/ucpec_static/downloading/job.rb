# frozen_string_literal: true

module UCPECStatic
  module Downloading
    class Job < UCPECStatic::Pipeline::AbstractJob
      include Dry::Effects::Handler.State(:file_count)
      include Dry::Effects::Handler.State(:total_size)
      include Dry::Effects::Handler.State(:total_size_mapping)

      option :base_url, Types::URL

      option :list_path, Types::Path

      option :output_path, Types::Path

      # @return [Pathname]
      attr_reader :destination_dir

      build_job! do |job|
        source UCPECStatic::Downloading::Source, job.base_url, job.list_path, job.destination_dir

        transform UCPECStatic::Downloading::Check

        transform UCPECStatic::Downloading::Download

        destination UCPECStatic::Downloading::Destination
      end

      around_kiba :track_file_count!

      around_kiba :track_total_size!

      around_kiba :track_total_size_mapping!

      def set_up
        @destination_dir = env.pwd.join(output_path).expand_path

        @destination_dir.mkpath

        super
      end

      private

      # @return [void]
      def track_file_count!
        with_file_count 0 do
          yield
        end
      end

      # @return [void]
      def track_total_size!
        with_total_size 0 do
          yield
        end
      end

      # @return [void]
      def track_total_size_mapping!
        with_total_size_mapping({}) do
          yield
        end
      end
    end
  end
end
