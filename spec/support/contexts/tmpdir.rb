# frozen_string_literal: true

RSpec.shared_context "tmpdir" do
  # @return [Pathname] the temporary directory for the test
  attr_reader :tmpdir

  around do |example|
    Dir.mktmpdir do |dir|
      @tmpdir = Pathname(dir)

      Dir.chdir(dir) do
        example.run
      end
    end
  end
end
