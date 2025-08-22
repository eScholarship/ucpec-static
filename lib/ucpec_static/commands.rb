# frozen_string_literal: true

module UCPECStatic
  module Commands
    extend Dry::CLI::Registry

    register "tei", aliases: %w[t] do |prefix|
      prefix.register "to-html", UCPECStatic::Commands::TEI::ToHTML, aliases: %w[2h h]
    end

    register "version", UCPECStatic::Commands::Version, aliases: %w[v -v --version]
  end
end
