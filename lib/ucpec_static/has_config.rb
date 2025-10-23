# frozen_string_literal: true

module UCPECStatic
  # A concern that exposes the application's config singleton
  # within an instance.
  module HasConfig
    extend ActiveSupport::Concern

    # @!attribute [r] config
    # @return [UCPECStatic::Config]
    def config
      UCPECStatic::Application[:config]
    end
  end
end
