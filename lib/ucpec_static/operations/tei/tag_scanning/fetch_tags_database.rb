# frozen_string_literal: true

module UCPECStatic
  module Operations
    module TEI
      module TagScanning
        # Fetch TEI tags from the database.
        class FetchTagsDatabase
          include Dry::Monads[:result]

          CREATE_TAGS_TABLE = <<~SQL
          CREATE TABLE IF NOT EXISTS tags (
            identifier TEXT NOT NULL,
            kind TEXT NOT NULL,
            name TEXT NOT NULL,
            depth INTEGER NOT NULL,
            occurrences INTEGER NOT NULL DEFAULT 0,
            UNIQUE(identifier, kind, name, depth)
          );
          SQL

          INDEX_TAGS_TABLE = <<~SQL
          CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);
          SQL

          CREATE_TAG_ATTRS_TABLE = <<~SQL
          CREATE TABLE IF NOT EXISTS tag_attrs (
            identifier TEXT NOT NULL,
            kind TEXT NOT NULL,
            tag_name TEXT NOT NULL,
            attr_name TEXT NOT NULL,
            attr_value TEXT NOT NULL,
            occurrences INTEGER NOT NULL DEFAULT 0,
            UNIQUE(identifier, kind, tag_name, attr_name, attr_value)
          );
          SQL

          INDEX_TAG_ATTRS_TABLE = <<~SQL
          CREATE INDEX IF NOT EXISTS idx_tag_attrs_attr_name ON tag_attrs(tag_name, attr_name);
          SQL

          # @param [Pathname, String] path
          # @return [Dry::Monads::Success(SQLite3::Database)]
          def call(path:)
            db = SQLite3::Database.new(path)

            db.execute(CREATE_TAGS_TABLE)
            db.execute(INDEX_TAGS_TABLE)
            db.execute(CREATE_TAG_ATTRS_TABLE)
            db.execute(INDEX_TAG_ATTRS_TABLE)

            Success db
          end
        end
      end
    end
  end
end
