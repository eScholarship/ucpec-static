# frozen_string_literal: true

require_relative "../helpers/spec_files"

module TestHelpers
  module TEIElements
    extend TestHelpers::SpecFiles::Helpers

    PARSED = spec_file_parse("sample-tei.xml")

    def parsed_at_xpath(...)
      parsed.doc.at_xpath(...)
    end

    def parsed_xpath(...)
      parsed.doc.xpath(...)
    end
  end
end

RSpec.shared_context "tei element" do
  include TestHelpers::TEIElements

  let(:parsed) { TestHelpers::TEIElements::PARSED }

  let(:input) { parsed }

  let(:node) { raise "Must set `node` in including context" }

  let(:element_attrs) do
    {
      input:,
      node:,
      name: node.name,
    }
  end

  let(:element) { described_class.new(**element_attrs) }
end

RSpec.configure do |c|
  c.include_context "tei element", tei_element: true
end
