# frozen_string_literal: true

RSpec.describe UCPECStatic::TEI::Nodes::Abstract do
  describe ".matches_tei_tag?" do
    it "only works with XML nodes or strings", :aggregate_failures do
      expect { described_class.matches_tei_tag?(1) }.to raise_error(NoMatchingPatternError)
      expect { described_class.matches_tei_tag?(nil) }.to raise_error(NoMatchingPatternError)

      expect { described_class.matches_tei_tag?("string") }.not_to raise_error
      expect { described_class.matches_tei_tag?(Nokogiri::XML::Element.new("element", Nokogiri::XML::Document.new)) }.not_to raise_error
    end
  end
end
