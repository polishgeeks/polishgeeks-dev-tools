module PolishGeeks
  module DevTools
    module Validators
      # It verifies if SimpleCov is available
      class Simplecov < Base
        # Regexp used to match code coverage from Simplecov generated output
        MATCH_REGEXP = /\(\d+.\d+\%\) covered/

        def valid?
          Object.const_defined?('SimpleCov') || (!output.nil? && output.length > 0)
        end

        # Searches if we have SimpleCov hooked to rspec
        def output
          @output ||= @stored_output.rspec[*MATCH_REGEXP]
        end
      end
    end
  end
end
