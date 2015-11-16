module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for Bundler Audit
      # Checks for vulnerable versions of gems in Gemfile.lock.
      # @see https://github.com/rubysec/bundler-audit
      class BundlerAudit < Base
        self.type = :validator

        # Executes this command
        # @return [String] command output
        def execute
          @output = Shell.new.execute('bundle-audit update 2>&1 > /dev/null; bundle-audit check')
        end

        # @return [Boolean] true if there were no vulnerabilities found
        def valid?
          @output.match(/Unpatched versions found/).nil?
        end
      end
    end
  end
end
