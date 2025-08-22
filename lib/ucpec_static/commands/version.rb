# frozen_string_literal: true

module UCPECStatic
  module Commands
    class Version < UCPECStatic::AbstractCommand
      desc "Print Version"

      def perform(*)
        write! UCPECStatic::VERSION
      end
    end
  end
end
