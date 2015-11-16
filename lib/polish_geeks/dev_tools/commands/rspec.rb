module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for Rspec validation
      # It informs us if our specs are working in a proper way
      class Rspec < Base
        self.type = :validator

        # Regexp used to match Rspec examples count
        EXAMPLES_REGEXP = /(\d+) examples/
        # Regexp used to match Rspec failures
        FAILURES_REGEXP = /(\d+) failures/
        # Regexp used to match Rspec pendings
        PENDING_REGEXP = /(\d+) pending/

        # Executes this command
        # @return [String] command output
        def execute
          @output = Shell.new.execute('bundle exec rspec spec')
        end

        # @return [Boolean] true if there were no Rspec failures, false otherwise
        def valid?
          output.include?('0 failures')
        end

        # @return [String] default label for this command
        def label
          examples = output.scan(EXAMPLES_REGEXP).flatten.first.to_i
          failures = output.scan(FAILURES_REGEXP).flatten.first.to_i
          pending = output.scan(PENDING_REGEXP).flatten.first.to_i

          "Rspec (#{examples} ex, #{failures} fa, #{pending} pe)"
        end
      end
    end
  end
end
