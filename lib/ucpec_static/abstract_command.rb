# frozen_string_literal: true

module UCPECStatic
  # @abstract
  class AbstractCommand < ::Dry::CLI::Command
    extend ActiveModel::Callbacks
    extend Dry::Core::ClassAttributes

    include Dry::Effects::Handler.Reader(:current_env)
    include Dry::Matcher.for(:run_job, with: Dry::Matcher::ResultMatcher)

    include UCPECStatic::Support::CallsCommonOperation

    option :verbose, required: false, desc: "Print verbose logging messages to STDERR.",
      type: :boolean, default: false, aliases: %w[-V]

    JobClass = Types.Inherits(UCPECStatic::Pipeline::AbstractJob)

    defines :job_klass, type: JobClass.optional

    defines :runs_job, type: Types::Bool

    job_klass nil

    runs_job false

    define_model_callbacks :perform

    around_perform :provide_current_env!

    # @return [UCPECStatic::Env::Runtime]
    attr_reader :env

    # @return [<String>]
    attr_reader :extra_args

    # @return [TTY::Prompt]
    attr_reader :prompt

    # @return [Boolean]
    attr_reader :verbose

    alias verbose? verbose

    delegate %i[logger] => :env

    def call(args: [], verbose: false, **opts)
      @verbose = verbose

      @env = call_operation!("env.build", verbose:)

      @extra_args = args

      @prompt = TTY::Prompt.new

      run_callbacks :perform do
        perform(**opts)
      end
    rescue ::UCPECStatic::HaltError => e
      warn "\n\n"
      warn Paint["ucpec-static halted!", :red, :bright]
      warn "\n"
      warn Paint[e.message.indent(2), :yellow, :italic]
    end

    def perform(*args, **kwargs)
      if runs_job?
        run_job(job_klass, *args, **kwargs) do |m|
          m.success do |result|
            logger.debug("Pipeline complete")

            on_success! result
          end

          m.failure do |*err|
            # :nocov:
            warn Paint["Something went wrong!", :red, :bright]
            warn Paint[err.flatten.join(" ").indent(2), :yellow, :italic]
            # :nocov:
          end
        end
      else
        # :nocov:
        raise NotImplementedError, "#{self.class}#perform not implemented"
        # :nocov:
      end
    end

    # @abstract
    def on_success!(...); end

    private

    # @return [nil, Class(UCPECStatic::Pipeline::AbstractJob)] klass
    def job_klass
      self.class.job_klass
    end

    # @return [void]
    def provide_current_env!
      with_current_env env do
        yield
      end
    end

    # @param [Class(UCPECStatic::Pipeline::AbstractJob)] klass
    # @return [void]
    def run_job(klass, ...)
      call_operation("pipeline.run", klass, ...)
    end

    def runs_job?
      self.class.runs_job && job_klass.present?
    end

    # @param [String] message
    # @param [<Symbol, String>] deets values to pass to `Paint`.
    def write!(message, *deets)
      write_raw! Paint[message, *deets]
    end

    def write_raw!(...)
      puts(...)
    end

    class << self
      # @param [Class(UCPECStatic::Pipeline::AbstractJob)] klass
      # @return [void]
      def runs_job!(klass)
        job_klass klass

        runs_job job_klass.present?
      end
    end
  end
end
