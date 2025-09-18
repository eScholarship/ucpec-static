# frozen_string_literal: true

RSpec.describe UCPECStatic::HaltError do
  let(:error_class) do
    Class.new(described_class) do
      message_format! <<~MSG
        Operation halted due to %{reason}.
      MSG
    end
  end

  it "sets the message correctly" do
    error = error_class.new(reason: "a test reason")

    expect(error.message).to eq("Operation halted due to a test reason.")
  end
end
