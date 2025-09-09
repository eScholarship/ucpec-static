# frozen_string_literal: true

module UCPECStatic
  module TEI
    module TagScanning
      class Job < UCPECStatic::Pipeline::AbstractJob
        include Dry::Effects::Handler.Reader(:db)
        include Dry::Effects::Handler.State(:file_count)
        include Dry::Effects::Handler.State(:total_nodes)
        include Dry::Effects::Handler.State(:total_nodes_mapping)

        option :directory, Types::Path
        option :db_path, Types::Path
        option :fresh, Types::Bool

        # @return [SQLite3::Database]
        attr_reader :db

        build_job! do |job|
          source UCPECStatic::TEI::TagScanning::Source, job.directory

          transform UCPECStatic::XML::Parse

          transform UCPECStatic::TEI::Only

          transform UCPECStatic::TEI::TagScanning::TraverseTags

          destination UCPECStatic::TEI::TagScanning::Destination
        end

        around_kiba :provide_db!

        around_kiba :track_file_count!

        around_kiba :track_total_nodes!

        around_kiba :track_total_nodes_mapping!

        def set_up
          @full_db_path = env.pwd.join(db_path)

          # :nocov:
          @full_db_path.unlink if fresh && @full_db_path.exist?
          # :nocov:

          @db = call_operation!("tei.tag_scanning.fetch_tags_database", path: @full_db_path)
        end

        private

        # @return [void]
        def provide_db!
          with_db db do
            yield
          end
        end

        # @return [void]
        def track_file_count!
          with_file_count 0 do
            yield
          end
        end

        # @return [void]
        def track_total_nodes!
          with_total_nodes 0 do
            yield
          end
        end

        # @return [void]
        def track_total_nodes_mapping!
          with_total_nodes_mapping({}) do
            yield
          end
        end
      end
    end
  end
end
