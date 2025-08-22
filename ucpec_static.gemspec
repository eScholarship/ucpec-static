# frozen_string_literal: true

require_relative "lib/ucpec_static/version"

Gem::Specification.new do |spec|
  spec.name = "ucpec_static"
  spec.version = UCPECStatic::VERSION
  spec.authors = ["Alexa Grey"]
  spec.email = ["alexa@castironcoding.com"]

  spec.summary = "TODO: Write a short summary, because RubyGems requires one."
  spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/eScholarship/ucpec_static"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["allowed_push_host"] = "https://does-not-exist.tld"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/eScholarship/ucpec_static"
  spec.metadata["changelog_uri"] = "https://github.com/eScholarship/ucpec_static/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 8.0", "< 9"
  spec.add_dependency "activesupport", ">= 8.0", "< 9"
  spec.add_dependency "anyway_config", "~> 2.7"
  spec.add_dependency "bootsnap", "~> 1.18"
  spec.add_dependency "down", ">= 5.4", "< 6"
  spec.add_dependency "dry-auto_inject", "~> 1.1.0"
  spec.add_dependency "dry-cli", "~> 1.3.0"
  spec.add_dependency "dry-container", "~> 0.11.0"
  spec.add_dependency "dry-core", "~> 1.1.0"
  spec.add_dependency "dry-effects", "~> 0.5.0"
  spec.add_dependency "dry-files", "~> 1.1.0"
  spec.add_dependency "dry-initializer", "~> 3.2.0"
  spec.add_dependency "dry-matcher", "~> 1.0.0"
  spec.add_dependency "dry-monads", "~> 1.9.0"
  spec.add_dependency "dry-schema", "~> 1.14.1"
  spec.add_dependency "dry-struct", "~> 1.8.0"
  spec.add_dependency "dry-system", "~> 1.2.4"
  spec.add_dependency "dry-transformer", "~> 1.0"
  spec.add_dependency "dry-types", "~> 1.8.3"
  spec.add_dependency "dry-validation", "~> 1.11.0"
  spec.add_dependency "kiba", "~> 4.0"
  spec.add_dependency "logger", "~> 1.7"
  spec.add_dependency "nokogiri", "~> 1.18.9"
  spec.add_dependency "paint", "~> 2.3.0"
  spec.add_dependency "pathname", ">= 0.4"
  spec.add_dependency "sqlite3", "2.7.3"
  spec.add_dependency "terminal-table", "~> 4.0.0"
  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "zeitwerk", "~> 2.7"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
