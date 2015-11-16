module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for RubyCritic statistics
      # It informs us if RubyCritic stats were generated
      class Rubycritic < Base
        self.type = :generator

        # Executes this command
        # @return [String] command output
        def execute
          @output = Shell.new.execute('bundle exec rubycritic ./app ./lib/')
        end
      end
    end
  end
end
