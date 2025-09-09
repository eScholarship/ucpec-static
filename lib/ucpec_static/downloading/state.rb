# frozen_string_literal: true

module UCPECStatic
  module Downloading
    module State
      include Dry::Effects.State(:file_count)
      include Dry::Effects.State(:total_size)
      include Dry::Effects.State(:total_size_mapping)

      AVERAGE_FILE_SIZE = 1.5.megabytes

      # @return [void]
      def update_total_size!(destination, amount)
        total_size_mapping[destination] = amount

        self.total_size = calculate_total_size
      end

      private

      # @return [Integer]
      def calculate_total_size
        to_estimate = (file_count - total_size_mapping.length).clamp(0, file_count)

        actual = total_size_mapping.each_value.sum(&:to_i)

        estimated = to_estimate * AVERAGE_FILE_SIZE

        self.total_size = actual + estimated
      end
    end
  end
end
