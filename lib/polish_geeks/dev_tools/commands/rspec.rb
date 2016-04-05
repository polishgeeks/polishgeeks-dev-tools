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
        FAILURES_REGEXP = /(\d+) failure/
        # Regexp used to match Rspec pendings
        PENDING_REGEXP = /(\d+) pending/

        # Executes this command
        # @return [String] command output
        def execute
          @output = Shell.new.execute('bundle exec rspec spec')
        end

        # @return [Boolean] true if there were no Rspec failures, false otherwise
        def valid?
          failures_count.zero? && disallow_pending_valid?
        end

        # @return [String] default label for this command
        def label
          "Rspec (#{examples_count} ex, #{failures_count} fa, #{pending_count} pe)"
        end

        private

        # @return [Integer] how many examples
        def examples_count
          output.scan(EXAMPLES_REGEXP).flatten.first.to_i
        end

        # @return [Integer] how many failures
        def failures_count
          output.scan(FAILURES_REGEXP).flatten.first.to_i
        end

        # @return [Integer] how many pending
        def pending_count
          output.scan(PENDING_REGEXP).flatten.first.to_i
        end

        # @return [Boolean] true if pending specs count is zero or we allow
        # pending tests, false otherwise
        def disallow_pending_valid?
          PolishGeeks::DevTools.config.rspec_disallow_pending? ? pending_count.zero? : true
        end
      end
    end
  end
end
