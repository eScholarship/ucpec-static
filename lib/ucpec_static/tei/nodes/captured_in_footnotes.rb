# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      module CapturedInFootnotes
        extend ActiveSupport::Concern

        include Dry::Effects.Reader(:rendering_root_children, default: false)
        include Dry::Effects.Reader(:footnotes)

        included do
          before_html_rendering :maybe_capture_in_footnotes!, if: :counts_as_footnote?
        end

        alias rendering_root_children? rendering_root_children

        # @return [Boolean]
        attr_reader :counts_as_footnote

        alias counts_as_footnote? counts_as_footnote

        private

        # @return [void]
        def maybe_capture_in_footnotes!
          return unless rendering_root_children?

          footnotes << self

          throw :abort
        end
      end
    end
  end
end
