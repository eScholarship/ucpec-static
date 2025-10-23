# frozen_string_literal: true

require_relative "lib"

BootLib::Require.from_gem("bootsnap", "bootsnap")

Bootsnap.setup(
  cache_dir:            "tmp/cache",          # Path to your cache
  development_mode:     false, # Current working environment, e.g. RACK_ENV, RAILS_ENV, etc
  load_path_cache:      true,                 # Optimize the LOAD_PATH with a cache
  compile_cache_iseq:   true,                 # Compile Ruby code into ISeq cache, breaks coverage reporting.
  compile_cache_yaml:   true,                 # Compile YAML into a cache
  compile_cache_json:   true,                 # Compile JSON into a cache
  readonly:             false,                 # Use the caches but don't update them on miss or stale entries.
)

require_relative "gems"

CONFIG_ROOT = Pathname.new(__dir__).join("../../config").realpath

Anyway::Settings.default_config_path = CONFIG_ROOT
