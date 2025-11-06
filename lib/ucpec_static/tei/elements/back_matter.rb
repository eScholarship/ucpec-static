# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Elements
      # @see https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-back.html
      class BackMatter < UCPECStatic::TEI::Nodes::Element
        matches_tei_tag! "back"

        # TODO: render only the endnotes (<div1 id="endnotes" type="bmsec">)
        # Don't render a wrapper tag, but still traverse children to capture endnotes
        def render_html
          render_html_content!
        end
      end
    end
  end
end
