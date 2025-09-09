# frozen_string_literal: true

module UCPECStatic
  # The entry point for the CLI.
  module Commands
    extend Dry::CLI::Registry

    register "tei", aliases: %w[t] do |prefix|
      prefix.register "download-multiple", UCPECStatic::Commands::TEI::DownloadMultiple, aliases: %w[dm]
      prefix.register "list-known-tags", UCPECStatic::Commands::TEI::ListKnownTags, aliases: %w[lkt]
      prefix.register "scan-tags", UCPECStatic::Commands::TEI::ScanTags, aliases: %w[scan]
      prefix.register "to-html", UCPECStatic::Commands::TEI::ToHTML, aliases: %w[2h h]
    end

    register "version", UCPECStatic::Commands::Version, aliases: %w[v -v --version]
  end
end
