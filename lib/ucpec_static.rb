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

# Must happen _after_ eager-loading.
UCPECStatic::Application.register("config", memoize: true) do
  UCPECStatic::Config.new
end

UCPECStatic::Application.register("tei.matchable_node_klasses", memoize: true) do
  UCPECStatic::TEI::Nodes::Abstract.matchable_node_klasses
end

UCPECStatic::Application.register("tei.known_tags", memoize: true) do
  UCPECStatic::Application["tei.matchable_node_klasses"].flat_map do |kls|
    kls.tei_tag_patterns.select { _1.kind_of?(String) }
  end.sort do |a, b|
    a.casecmp(b)
  end.freeze
end

UCPECStatic::Application.finalize!
