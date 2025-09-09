# frozen_string_literal: true

module UCPECStatic
  module TEI
    # An error raised when a TEI document is invalid.
    class InvalidDocumentError < UCPECStatic::HaltError
      message_format! "Invalid TEI document encountered: %<identifier>s"
    end
  end
end
