# frozen_string_literal: true

require_relative "boot/setup"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/boot")
loader.inflector.inflect(
  "cli" => "CLI",
  "html" => "HTML",
  "html_conversion" => "HTMLConversion",
  "tei" => "TEI",
  "tei_nodes" => "TEINodes",
  "to_html" => "ToHTML",
  "ucpec" => "UCPEC",
  "ucpec_static" => "UCPECStatic",
  "xml" => "XML"
)
loader.setup

module UCPECStatic
  class Application < ::Dry::System::Container
    configure do |config|
      config.inflector = Dry::Inflector.new do |inflections|
        inflections.acronym("CLI")
        inflections.acronym("HTML")
        inflections.acronym("TEI")
        inflections.acronym("UCPEC")
        inflections.acronym("XML")
      end

      config.root = Pathname(File.join(__dir__, "ucpec_static"))

      config.component_dirs.add "operations" do |dir|
        dir.auto_register = true
        dir.namespaces.add nil, key: nil, const: "ucpec_static/operations"
        dir.memoize = true
      end
    end
  end

  Deps = Dry::AutoInject(Application)
end

loader.eager_load

UCPECStatic::Application.finalize!
