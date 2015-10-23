module PolishGeeks
  module DevTools
    module Command
      # Command wrapper for Simple code coverage analysing
      # It informs us if we didn't reach a proper code coverage level
      class Simplecov < Base
        self.type = :validator

        # Regexp used to match float number from coverage
        NUMBER_REGEXP = /(\d+[.]\d+)/

        # @return [Float] code coverage level
        def to_f
          output[*NUMBER_REGEXP].to_f
        end

        # Executes this command
        # @return [String] command output
        def execute
          @output = stored_output.rspec[*Validators::Simplecov::MATCH_REGEXP]
        end

        # @return [Boolean] true if code coverage level is higher or equal to expected
        def valid?
          to_f >= threshold
        end

        # @return [String] default label for this command
        def label
          "SimpleCov covered #{to_f}%, required #{threshold}%"
        end

        # @return [String] message that should be printed when code coverage level is not met
        def error_message
          'SimpleCov coverage level needs to be ' \
            "#{threshold}%#{threshold == limit ? '' : ' or more'}, was #{to_f}%"
        end

        private

        # @return [Float] desired threshold
        def threshold
          DevTools.config.simplecov_threshold.to_f
        end

        # @return [Float] maximum threshold value
        def limit
          100.0
        end
      end
    end
  end
end
