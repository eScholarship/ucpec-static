# frozen_string_literal: true

RSpec.describe UCPECStatic::XML::Parse do
  let(:transformer) { described_class.new }

  def expect_transforming(input)
    result = Dry::Monads.Success(input)

    expect(transformer.process(result))
  end

  context "with TEI content" do
    let(:input) { spec_file_read("sample-tei.xml") }

    it "parses correctly" do
      expect_transforming(input).to succeed.with(a_kind_of(UCPECStatic::TEI::Parsed))
    end
  end

  context "with arbitrary XML" do
    let(:input) { "<root><child>Content</child></root>" }

    it "parses correctly" do
      expect_transforming(input).to succeed.with(a_kind_of(UCPECStatic::XML::Parsed))
    end
  end

  context "with anything else" do
    let(:input) { ["an", "array"] }

    it "fails" do
      expect_transforming(input).to be_a_monadic_failure.with_key(:invalid_xml_input)
    end
  end
end
