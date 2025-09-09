# frozen_string_literal: true

module UCPECStatic
  module TEI
    module TagScanning
      class Source < UCPECStatic::Pipeline::AbstractSource
        include State

        param :directory, Types::Path

        def produce_each
          unless directory.exist? && directory.directory?
            # :nocov:
            logger.error "TEI source #{directory} does not exist or is not a directory"

            return
            # :nocov:
          end

          self.file_count = directory.glob("*.xml").reject do |path|
            path.basename.fnmatch("*.mets.xml")
          end.count

          logger.warn "Got #{file_count} probable XML files"

          directory.glob("*.xml").each do |path|
            yield path
          end
        end
      end
    end
  end
end
