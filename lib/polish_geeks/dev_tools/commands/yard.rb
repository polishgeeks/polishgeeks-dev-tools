module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for Yard statistics
      # @note It validates if everything is well documented
      class Yard < Base
        self.type = :validator

        # Regexp used to match Yard output to check if there are things that
        # are not documented or that include warnings
        MATCH_REGEXP = /(Undocumented Objects|warn)/i

        # Executes this command
        # @return [String] command output
        def execute
          @output = Shell.new.execute("bundle exec yard stats #{options}")
        end

        # @return [Boolean] true if everything is documented and without warnings
        def valid?
          output[MATCH_REGEXP].nil?
        end

        private

        # Settings for yard - they are directly taken from yardopts file in config dir
        # @return [String] yard options that should be used to generate documentation
        def options
          config = File.join(DevTools.gem_root, 'config', 'yardopts')
          File.readlines(config).join(' ').delete("\n") + ' --list-undoc'
        end
      end
    end
  end
end
