module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for Rubocop Rspec validation
      # It informs us if rspec specs are formatted in a proper way
      class RubocopRspec < Rubocop
        self.config_name = '.rubocop.yml'
        self.type = :validator
        self.validators = [
          Validators::Rubocop
        ]

        # Executes this command
        # @return [String] command output
        def execute
          cmd = ["bundle exec rubocop #{PolishGeeks::DevTools.app_root}"]
          cmd << "-c #{config}" if config?
          cmd << '--require rubocop-rspec'
          @output = Shell.new.execute(cmd.join(' '))
        end

        # @return [String] default label for this command
        def label
          "RubocopRspec (#{files_count} files, #{offenses_count} offenses)"
        end
      end
    end
  end
end
