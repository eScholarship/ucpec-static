# frozen_string_literal: true

module UCPECStatic
  module TEI
    module TagScanning
      class TraverseTags < UCPECStatic::Pipeline::AbstractTransformer
        include HasProgressBar
        include State

        after_initialize :prepare_statements!

        # @return [SQLite3::Statement]
        attr_reader :upsert_tags_stmt

        # @return [SQLite3::Statement]
        attr_reader :upsert_tag_attrs_stmt

        # @param [Dry::Monads::Success(UCPECStatic::TEI::Parsed)] result
        # @return [Dry::Monads::Success(UCPECStatic::TEI::Parsed)]
        def process(result)
          result.bind do |parsed|
            update_total_size!(parsed.identifier, parsed.nodes_count)

            refresh_bar_total!

            parsed.traverse_header do |node|
              upsert_header_tag!(parsed, node)
            end

            parsed.traverse_body do |node|
              upsert_body_tag!(parsed, node)
            end
          end

          return result
        end

        private

        def depth_for(node)
          # Subtract 1 to account for the XML :document
          node.ancestors.size - 1
        end

        def upsert_header_tag!(...)
          upsert_tag!("header", ...)
        end

        def upsert_body_tag!(...)
          upsert_tag!("body", ...)
        end

        def upsert_tag!(kind, parsed, node)
          return unless node.element?

          name = node.name.to_s

          depth = depth_for(node)

          bindings = {
            "identifier" => parsed.identifier,
            "kind" => kind,
            "name" => name,
            "depth" => depth,
          }

          upsert_tags_stmt.execute bindings

          node.attributes.each do |attr_name, attr_value|
            attr_bindings = bindings.without("name", "depth").merge(
              "tag_name" => name,
              "attr_name" => attr_name.to_s,
              "attr_value" => attr_value.to_s,
            )

            upsert_tag_attrs_stmt.execute attr_bindings
          end

          bar.increment
        end

        def progress_bar_title
          "Scanning TEI Nodes..."
        end

        def progress_bar_total
          [total_nodes, calculate_total_nodes, AVERAGE_NODES_COUNT * 10].detect(&:nonzero?)
        end

        def prepare_statements!
          @upsert_tags_stmt = db.prepare(<<~SQL.strip)
          INSERT INTO tags (identifier, kind, name, depth, occurrences)
          VALUES (:identifier, :kind, :name, :depth, 1)
          ON CONFLICT (identifier, kind, name, depth) DO UPDATE SET
            occurrences = tags.occurrences + 1
          ;
          SQL

          @upsert_tag_attrs_stmt = db.prepare(<<~SQL.strip)
          INSERT INTO tag_attrs (identifier, kind, tag_name, attr_name, attr_value, occurrences)
          VALUES (:identifier, :kind, :tag_name, :attr_name, :attr_value, 1)
          ON CONFLICT (identifier, kind, tag_name, attr_name, attr_value) DO UPDATE SET
            occurrences = tag_attrs.occurrences + 1
          ;
          SQL
        end
      end
    end
  end
end
