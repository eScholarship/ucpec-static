# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      class Root < UCPECStatic::TEI::Nodes::Element
        include Dry::Effects::Handler.Reader(:footnotes)
        include Dry::Effects::Handler.Reader(:rendering_root_children)

        before_prepare_html :prepare_footnotes!

        around_html_rendering :capture_footnotes!

        around_render_children :rendering_root_children!

        after_render_children :render_footnotes!, if: :has_footnotes?

        matches_tei_tag! "TEI"

        matches_tei_tag! "TEI.2"

        uses_html_tag! :main

        # @return [Array<UCPECStatic::TEI::Nodes::Abstract>]
        attr_reader :footnotes

        memoize def header
          find_first_descendant { _1.kind_of?(DocumentHeader) }
        end

        memoize def text
          find_first_descendant { _1.kind_of?(Text) }
        end

        def has_footnotes?
          footnotes.any?
        end

        private

        # @return [void]
        def capture_footnotes!
          with_footnotes(footnotes) do
            yield
          end
        end

        # @return [void]
        def rendering_root_children!
          with_rendering_root_children(true) do
            yield
          end
        end

        # @return [void]
        def prepare_footnotes!
          @footnotes = []
        end

        # @return [void]
        def render_footnotes!
          wrap_with_tag!("footer", class: "footnotes") do
            html_builder.ul do
              footnotes.each do |note|
                html_builder.li do
                  note.to_html
                end
              end
            end
          end
        end
      end
    end
  end
end
