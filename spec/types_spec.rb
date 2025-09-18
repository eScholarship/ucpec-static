# frozen_string_literal: true

RSpec.describe UCPECStatic::Types do
  describe "Path" do
    it "converts strings and accepts pathnames, with an error otherwise", :aggregate_failures do
      expect(UCPECStatic::Types::Path[Pathname("path")]).to be_a_kind_of(Pathname)
      expect(UCPECStatic::Types::Path["input"]).to be_a_kind_of(Pathname)
      expect do
        UCPECStatic::Types::Path[123]
      end.to raise_error Dry::Types::ConstraintError
    end
  end
end
