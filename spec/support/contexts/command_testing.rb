# frozen_string_literal: true

module TestHelpers
  class CommandTester
    include Dry::Initializer[undefined: false].define -> do
      option :rspec_context, Types::Any

      option :args, Types::Array

      option :effects, Types::Array
    end

    def expectation
      @expectation ||= effects.reduce(&:and)
    end
  end

  class CommandDSL
    include Dry::Initializer[undefined: false].define -> do
      option :rspec_context, Types::Any

      option :initial_args, Types::Array, default: proc { Dry::Core::Constants::EMPTY_ARRAY }
    end

    def initialize(...)
      super

      @effects = []

      @successful = true

      @out = nil
      @err = nil
    end

    def exits!
      @successful = false
    end

    def effect!(effect)
      @effects << effect
    end

    def to_stdout(value)
      @out = value
    end

    def to_stderr(value)
      @err = value
    end

    def no_stdout!
      to_stdout rspec_context.be_blank
    end

    def no_stderr!
      to_stderr rspec_context.be_blank
    end

    private

    def compile_args
      [*initial_args]
    end

    def compile_effects
      [].tap do |eff|
        if @successful
          eff << rspec_context.execute_safely
        else
          eff << rspec_context.raise_error(SystemExit)
        end

        if @out
          eff << rspec_context.output(@out).to_stdout
        end

        if @err
          eff << rspec_context.output(@err).to_stderr
        end

        eff.concat(@effects)
      end
    end

    def to_tester
      args = compile_args

      effects = compile_effects

      CommandTester.new(rspec_context:, args:, effects:)
    end
  end

  module CommandTesting
    module ExampleHelpers
      def expect_command!(*initial_args)
        initial_args.flatten!

        dsl = CommandDSL.new(rspec_context: self, initial_args:)

        yield dsl

        tester = dsl.__send__(:to_tester)

        expect do
          run_command!(*tester.args)
        end.to tester.expectation
      end

      def run_command!(*args)
        args.flatten!

        arguments = [*args].map(&:to_s)

        Dry::CLI.new(UCPECStatic::Commands).call(arguments:)
      end
    end
  end
end

RSpec.shared_context "command testing" do |config|
  let!(:command_name) { "ucpec-static" }
end

RSpec.configure do |config|
  config.include TestHelpers::CommandTesting::ExampleHelpers, type: :command
  config.include_context "command testing", type: :command
end
