module PolishGeeks
  module DevTools
    # Basic logger used to print output from commands
    class Logger
      # Regexp used to get only the class name without module names
      CLASS_NAME_REGEXP = /^.*::/

      # Method will print appropriate output with colors and comments
      # @param [PolishGeeks::DevTools::Commands::Base] task that was executed
      # @raise [PolishGeeks::DevTools::Logger::RequirementsError] raised when task
      #   has failed
      # @example Log output of a current_task
      #   PolishGeeks::DevTools::Logger.new.log(current_task) #=> console output
      def log(task)
        if task.class.generator? || task.valid?
          info(task)
        else
          fatal(task)
          raise Errors::RequirementsError
        end
      end

      private

      # Will print message when task didn't fail while running
      # @note Handles also generators that never fail
      # @param [PolishGeeks::DevTools::Commands::Base] task that was executed
      # @raise [PolishGeeks::DevTools::Errors::UnknownTaskType] raised when task type is
      #   not supported (we don't know how to handle it)
      def info(task)
        msg = 'GENERATED' if task.class.generator?
        msg = 'OK' if task.class.validator?

        raise Errors::UnknownTaskType unless msg

        printf('%-50s %2s', "#{label(task)} ", "\e[32m#{msg}\e[0m\n")
      end

      # Will print message when task did fail while running
      # @param [PolishGeeks::DevTools::Commands::Base] task that was executed
      def fatal(task)
        printf('%-30s %20s', "#{label(task)} ", "\e[31mFAILURE\e[0m\n\n")
        puts task.error_message + "\n"
      end

      # Generates a label describing a given task
      # @note Will use a task class name if task doesn't respond to label method
      # @param [PolishGeeks::DevTools::Commands::Base] task that was executed
      # @return [String] label describing task
      # @example Get label for a current_task task
      #   label(current_task) #=> 'Rubocop'
      def label(task)
        label = task.label if task.respond_to?(:label)
        label || task.class.to_s.gsub(CLASS_NAME_REGEXP, '')
      end
    end
  end
end
