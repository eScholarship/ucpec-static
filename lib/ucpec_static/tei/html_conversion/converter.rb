# frozen_string_literal: true

module UCPECStatic
  module TEI
    module HTMLConversion
      # A converter class that wraps a {Nokogiri::HTML5::Builder} around
      # a {UCPECStatic::TEI::Nodes::Abstract#to_html html conversion process}.
      #
      # @see UCPECStatic::Operations::TEI::HTMLConversion::Convert
      class Converter < Support::HookBased::Actor
        include Dry::Effects::Handler.Reader(:html_builder)
        include Dry::Initializer[undefined: false].define -> do
          param :node, Types.Instance(::UCPECStatic::TEI::Nodes::Abstract)
        end

        # @return [Nokogiri::HTML5::Builder]
        attr_reader :builder

        def call
          run_callbacks :execute do
            yield convert!
          end

          built = builder.to_html

          reparsed = Nokogiri::HTML5(built)

          # Get the contents of the body tag only
          fragment = reparsed.at_css("body").children.to_html

          # Format the HTML for readability on export
          formatted = HtmlBeautifier.beautify(fragment)

          Success formatted
        end

        wrapped_hook! def convert
          @builder = Nokogiri::HTML5::Builder.new do |html|
            with_html_builder(html) do
              # This will recursively call #to_html on all child nodes
              node.to_html
            end
          end

          super
        end
      end
    end
  end
end
