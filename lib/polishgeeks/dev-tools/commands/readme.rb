module PolishGeeks
  module DevTools
    module Commands
      # Checks README.rb exists
      class Readme < Base
        self.type = :validator

        # Executes this command
        # @return [String] command output
        def execute
          readme = File.join(::PolishGeeks::DevTools.app_root, 'README.md')
          @output = File.exist?(readme)
        end

        # @return [String] label with this validator description
        def label
          'README.rb required'
        end

        # @return [String] error message
        def error_message
          "README.rb doesn't exist!"
        end

        # @return [Boolean] true if README.rb exist
        def valid?
          @output
        end
      end
    end
  end
end
