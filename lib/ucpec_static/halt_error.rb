# frozen_string_literal: true

module UCPECStatic
  class HaltError < StandardError
    extend Dry::Core::ClassAttributes

    defines :message_format, type: Types::String

    message_format "Application operation halted."

    # @return [{ Symbol => Object }]
    attr_reader :details

    def initialize(**details)
      @details = details

      message = message_format % details

      super(message)
    end

    private

    # @return [String]
    def message_format
      self.class.message_format
    end

    class << self
      def message_format!(message)
        message_format message.strip_heredoc.strip
      end
    end
  end
end
