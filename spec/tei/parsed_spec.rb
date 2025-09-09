# frozen_string_literal: true

RSpec.describe UCPECStatic::TEI::Parsed do
  let(:parsed) { spec_file_parse("sample-tei.xml") }

  subject { parsed }

  it "grabs children from the root" do
    expect(subject.children).to have(3).items
  end

  it { is_expected.not_to be_mets }

  it { is_expected.to be_tei }

  it { is_expected.to have_root }

  it { is_expected.not_to have_default_identifier }

  it { is_expected.to have_tei_root_id }
end
