# frozen_string_literal: true

RSpec.describe UCPECStatic::Operations::TEI::DetermineNodeKlass, type: :operation do
  let!(:xml_document) { Nokogiri::XML(spec_file_read("sample-tei.xml")) }

  it "can find the right node klasses for the specific nodes", :aggregate_failures do
    expect_calling_with(xml_document).to succeed.with(UCPECStatic::TEI::Nodes::Unknown)
    expect_calling_with(xml_document.at_xpath("//comment()[1]")).to succeed.with(UCPECStatic::TEI::Nodes::Comment)
    expect_calling_with(xml_document.at_xpath("//text()[1]")).to succeed.with(UCPECStatic::TEI::Nodes::TextContent)

    expect_calling_with(xml_document.root).to succeed.with(UCPECStatic::TEI::Elements::Root)
    expect_calling_with(xml_document.at_xpath("//body")).to succeed.with(UCPECStatic::TEI::Elements::Body)
    expect_calling_with(xml_document.at_xpath("//text")).to succeed.with(UCPECStatic::TEI::Elements::Text)
  end

  it "can handle a truly unknown tag" do
    doc = Nokogiri::XML("<truly-unknown-tag-that-will-never-exist/>")

    expect_calling_with(doc.root).to succeed.with(UCPECStatic::TEI::Nodes::FallbackElement)
  end

  it "explodes when given a non-XML node" do
    expect do
      operation.call(nil)
    end.to raise_error(TypeError, /xml node/i)
  end
end
