module PolishGeeks
  module DevTools
    module Commands
      # Validator used to check if all files don't contain merge conflict
      # @example: <<<<<<< HEAD
      class GitConflicts < Base
        self.type = :validator

        attr_reader :counter

        # Regexp that we want to use to catch files with git conflicts like <<<<<<< HEAD
        CHECKED_REGEXP = '^<<<<<<<[ \t]'.freeze

        # Executes this command and set output variable
        def execute
          @output = invalid_files
        end

        # @return [Boolean] true if all files don't contain git conflict
        def valid?
          output.empty?
        end

        # @return [String] default label for this command
        def label
          'Git conflicts'
        end

        # @return [String] message that should be printed when some files has git conflict
        def error_message
          "Following files have git conflicts: \n#{output.join("\n")}\n"
        end

        private

        # @return [Array<String>] list of files which contain merge conflict marker
        def invalid_files
          cmd = "grep -r -l '#{CHECKED_REGEXP}' . | xargs -n1 basename"
          PolishGeeks::DevTools::Shell.new.execute(cmd).split("\n")
        end
      end
    end
  end
end
