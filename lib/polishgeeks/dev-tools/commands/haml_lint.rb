module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for Haml lint validation
      # It informs us if haml is formatted in a proper way
      # @see https://github.com/causes/haml-lint
      class HamlLint < Base
        self.type = :validator

        # Executes this command
        # @return [String] command output
        def execute
          loc_config = File.join(DevTools.gem_root, 'config', 'haml-lint.yml')
          app_config = File.join(DevTools.app_root, '.haml-lint.yml')

          config = File.exist?(app_config) ? app_config : loc_config

          @output = Shell.new.execute("bundle exec haml-lint -c #{config} app/views")
        end

        # @return [Boolean] true if there were no Rubocop offenses detected
        def valid?
          @output.to_s.empty?
        end
      end
    end
  end
end
