# frozen_string_literal: true

module UCPECStatic
  module Downloading
    class Source < UCPECStatic::Pipeline::AbstractSource
      include State

      param :base_url, Types::URL

      param :list_path, Types::Path

      param :destination_dir, Types::Path

      def produce_each
        # We enumerate twice here because we want to establish `file_count`,
        # before any downloading occurs, so as to accurately gauge progress
        self.file_count = list_path.each_line.count

        list_path.each_line do |potential_uri|
          uri = potential_uri.strip.presence

          # :nocov:
          next if uri.blank?
          # :nocov:

          url = URI.join(base_url, uri)

          destination = destination_dir.join(uri)

          tuple = { url:, destination:, }

          yield tuple
        end
      end
    end
  end
end
