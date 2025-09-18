# frozen_string_literal: true

RSpec.describe UCPECStatic::Commands::Version, type: :command do
  it "outputs the version" do
    expect_command!("version") do |c|
      c.to_stdout /#{UCPECStatic::VERSION}/

      c.no_stderr!
    end
  end
end
