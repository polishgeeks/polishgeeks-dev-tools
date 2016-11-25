module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for Rubocop validation
      # It informs us if code is formatted in a proper way
      class Rubocop < Base
        self.config_manager = ConfigManager.new('rubocop.yml')
        self.type = :validator

        # Regexp used to get number of inspected files
        FILES_REGEXP = /(\d+) files inspected/
        # Regexp used to get number of offenses detected
        OFFENSES_REGEXP = /(\d+) offense.* detected/

        # Executes this command
        # @return [String] command output
        def execute
          cmd = ["bundle exec rubocop #{PolishGeeks::DevTools.app_root}"]
          cmd << "-c #{self.class.config_manager.path}" if self.class.config_manager.present?
          cmd << '--require rubocop-rspec' if Config.config.rubocop_rspec?
          cmd << '--display-cop-names'
          @output = Shell.new.execute(cmd.join(' '))
        end

        # @return [Boolean] true if there were no Rubocop offenses detected
        def valid?
          offenses_count.zero?
        end

        # @return [String] default label for this command
        def label
          msg = []
          msg << 'Rubocop'
          msg << 'with RSpec' if Config.config.rubocop_rspec?
          msg << "(#{files_count} files, #{offenses_count} offenses)"
          msg.join(' ')
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
