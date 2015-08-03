module PolishGeeks
  module DevTools
    module Command
      # Command wrapper for Simplecov statistics
      # It informs us if Simplecov coverage stats were generated
      class Simplecov < Base
        self.type = :validator

        # Regexp used to match code coverage from Simplecov generated output
        MATCH_REGEXP = /\(\d+.\d+\%\) covered/

        # Executes this command
        # @return [String] command output
        # @note Since this command wrapper is using external output
        #   information (from Rspec), it doesn't execute any shell tasks
        def execute
          @output = stored_output.rspec
        end

        # @return [Boolean] true if Simplecov coverage was generated
        def valid?
          output[MATCH_REGEXP].length > 0
        end

        # @return [String] default label for this command
        def label
          "Simplecov #{output[MATCH_REGEXP]}"
        end
      end
    end
  end
end
