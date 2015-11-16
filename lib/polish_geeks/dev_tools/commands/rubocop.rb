module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for Rubocop validation
      # It informs us if code is formatted in a proper way
      class Rubocop < Base
        self.type = :validator

        # Regexp used to get number of inspected files
        FILES_REGEXP = /(\d+) files inspected/
        # Regexp used to get number of offenses detected
        OFFENSES_REGEXP = /(\d+) offense.* detected/

        # Executes this command
        # @return [String] command output
        def execute
          loc_config = File.join(DevTools.gem_root, 'config', 'rubocop.yml')
          app_config = File.join(DevTools.app_root, '.rubocop.yml')

          config = File.exist?(app_config) ? app_config : loc_config
          cmd = "bundle exec rubocop -c #{config} #{PolishGeeks::DevTools.app_root}"

          @output = Shell.new.execute(cmd)
        end

        # @return [Boolean] true if there were no Rubocop offenses detected
        def valid?
          offenses_count == 0
        end

        # @return [String] default label for this command
        def label
          "Rubocop (#{files_count} files, #{offenses_count} offenses)"
        end

        private

        # @return [Integer] number of files inspected
        def files_count
          output.scan(FILES_REGEXP).flatten.first.to_i
        end

        # @return [Integer] number of offences found
        def offenses_count
          output.scan(OFFENSES_REGEXP).flatten.first.to_i
        end
      end
    end
  end
end
