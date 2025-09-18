# frozen_string_literal: true

module UCPECStatic
  module TEI
    module TagScanning
      module State
        include Dry::Effects.Reader(:db)
        include Dry::Effects.State(:file_count)
        include Dry::Effects.State(:total_nodes)
        include Dry::Effects.State(:total_nodes_mapping)

        AVERAGE_NODES_COUNT = 76_000

        # @param [String] identifier
        # @param [Integer] amount
        # @return [void]
        def update_total_size!(identifier, amount)
          total_nodes_mapping[identifier] = amount

          self.total_nodes = calculate_total_nodes
        end

        private

        # @return [Integer]
        def calculate_total_nodes
          to_estimate = (file_count - total_nodes_mapping.length).clamp(0, file_count)

          actual = total_nodes_mapping.each_value.sum

          estimated = to_estimate * AVERAGE_NODES_COUNT

          actual + estimated
        end
      end
    end
  end
end
