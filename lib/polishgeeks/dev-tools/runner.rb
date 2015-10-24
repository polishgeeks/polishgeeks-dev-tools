module PolishGeeks
  module DevTools
    # Class used to execute appropriate commands based on config settings
    class Runner
      # Executes the whole tool
      # @param logger [PolishGeeks::DevTools::Logger] logger instance
      # @example Run all defined elements
      #   PolishGeeks::DevTools::Runner.new.execute(
      #     PolishGeeks::DevTools::Logger.new
      #   )
      def execute(logger)
        output = OutputStorer.new

        Config::COMMANDS.each do |command|
          next unless DevTools.config.public_send(:"#{command}?")

          klass = command.to_s.gsub(/(?<=_|^)(\w)/, &:upcase).gsub(/(?:_)(\w)/, '\1')
          cmd = Object.const_get("PolishGeeks::DevTools::Commands::#{klass}").new
          cmd.stored_output = output
          cmd.validation!
          cmd.execute
          output.public_send(:"#{command}=", cmd.output)
          logger.log(cmd)
        end
      end
    end
  end
end
