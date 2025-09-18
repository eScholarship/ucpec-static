# frozen_string_literal: true

RSpec.describe UCPECStatic::TEI::Elements::Heading, :tei_element do
  let(:node) { parsed_at_xpath("//head") }

  it "assigns the TEI rend attr to HTML class" do
    expect(element.compiled_html_attributes[:class]).to include(node["rend"])
  end

  context "with no parent div" do
    it "renders the correct tag" do
      expect(element.build_html_tag).to eq "h6"
    end
  end

  describe ".matches_tei_tag!" do
    it "matches 'head'" do
      expect(described_class).to match_tei_tag("head")
    end

    it "does not match other tags", :aggregate_failures do
      expect(described_class).not_to match_tei_tag("div")
      expect(described_class).not_to match_tei_tag("p")
      expect(described_class).not_to match_tei_tag("title")
    end
  end
end
