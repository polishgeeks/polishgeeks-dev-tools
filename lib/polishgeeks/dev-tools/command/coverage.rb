module PolishGeeks
  module DevTools
    module Command
      # Command wrapper for Simple code coverage analysing
      # It informs us if we didn't reach a proper code coverage level
      class Coverage < Base
        self.type = :validator

        # Regexp used to match code coverage level
        MATCH_REGEXP = /\(\d+.\d+\%\) covered/
        # Regexp used to match float number from coverage
        NUMBER_REGEXP = /(\d+[.]\d+)/

        # @return [Float] code coverage level
        def to_f
          output[*NUMBER_REGEXP].to_f
        end

        # Executes this command
        # @return [String] command output
        def execute
          @output = stored_output.rspec[*MATCH_REGEXP]
        end

        # @return [Boolean] true if code coverage level is higher or equal to expected
        def valid?
          to_f >= DevTools.config.simplecov_threshold
        end

        # @return [String] default label for this command
        def label
          "Coverage #{to_f}% covered - #{DevTools.config.simplecov_threshold}% required"
        end

        # @return [String] message that should be printed when code coverage level is not met
        def error_message
          threshold = DevTools.config.simplecov_threshold
          "Coverage level should more or equal to #{threshold}%. was: #{to_f}"
        end
      end
    end
  end
end
