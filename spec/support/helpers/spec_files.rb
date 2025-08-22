# frozen_string_literal: true

module TestHelpers
  module SpecFiles
    module Helpers
      def spec_file_read(*parts)
        spec_file_path(*parts).read
      end

      def spec_file_path(*parts)
        TestHelpers::SPEC_DATA.join(*parts)
      end
    end
  end
end

RSpec.configure do |c|
  c.include TestHelpers::SpecFiles::Helpers
  c.extend TestHelpers::SpecFiles::Helpers
end
