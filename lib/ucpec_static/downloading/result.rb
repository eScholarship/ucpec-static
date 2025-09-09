# frozen_string_literal: true

module UCPECStatic
  module Downloading
    class Result < UCPECStatic::Support::FlexibleStruct
      include UCPECStatic::Support::Successful

      attribute :url, Types::URL

      attribute :destination, Types::Path
    end
  end
end
