# frozen_string_literal: true

module UCPECStatic
  class Config < UCPECStatic::Support::ApplicationConfig
    config_name :ucpec_static
    env_prefix :ucpec_static

    attr_config asset_url: nil

    # @param [String, nil] path
    # @return [String, nil]
    def join_asset_url(path)
      # :nocov:
      return path if path.blank? || asset_url.blank?
      # :nocov:

      "#{asset_url.chomp('/')}/#{path}"
    end
  end
end
