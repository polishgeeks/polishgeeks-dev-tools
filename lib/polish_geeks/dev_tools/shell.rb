module PolishGeeks
  module DevTools
    # Class wrapping shell commands executing
    class Shell
      # Executes a given command in a system shell and returns its output
      # @param [String] command that should be executed
      # @return [String] executed command output
      # @example Run 'ls' command and assing the output
      #   ls = PolishGeeks::DevTools::Shell.new.execute('ls')
      #   print ls #=> 'app app.rb Capfile ...'
      def execute(command)
        `#{command}`
      end
    end
  end
end
