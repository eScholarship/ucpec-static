# frozen_string_literal: true

RSpec.describe UCPECStatic::TEI::Elements::Root, :tei_element do
  let(:element) { spec_file_parse_nodes("small-tei.xml") }

  let(:node) { parsed_at_xpath("/TEI.2") }

  describe "#traverse" do
    it "can traverse itself" do
      expect { |b| element.traverse(&b) }.to yield_control.exactly(32).times
    end

    it "yields itself first" do
      expect { |b| element.traverse.select { _1.try(:name) == "TEI.2" }.each(&b) }.to yield_with_args(element)
    end
  end

  describe "#header" do
    it "searches children" do
      expect(element.header).to be_a_kind_of(UCPECStatic::TEI::Elements::DocumentHeader)
    end
  end

  describe "#text" do
    it "searches children" do
      expect(element.text).to be_a_kind_of(UCPECStatic::TEI::Elements::Text)
    end
  end
end
