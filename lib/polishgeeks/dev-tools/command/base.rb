module PolishGeeks
  module DevTools
    # Module encapsulating all the commands that we use to check/verify code
    module Command
      # Base class for all the commands
      # @abstract Subclass and use
      class Base
        # Raised when we specify a framework in which a given command can be executed
        # and it is not present (not detected)
        class MissingFramework < StandardError; end

        attr_reader :output
        # stored_output [PolishGeeks::DevTools::OutputStorer] storer with results of previous
        #   commands (they might use output from previous/other commands)
        attr_accessor :stored_output

        # Available command types. We have validators that check something
        # and that should have a 'valid?' method and that check for errors, etc
        # and generators that are executed to generate some stats, docs, etc
        TYPES = %i( validator generator )

        class << self
          attr_accessor :type
          attr_accessor :framework

          TYPES.each do |type|
            # @return [Boolean] if it is a given type command
            define_method :"#{type}?" do
              self.type == type
            end
          end
        end

        # When we will try to use a given command, we need to check if it requires
        # a given framework (Rails, Sinatra), if so, then we need to check if it is
        # present, because without it a given command cannot run
        def initialize
          ensure_framework_if_required
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        def execute
          fail NotImplementedError
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        #   if it is a validator type (or no implementation required when
        #   it is a validator)
        def valid?
          fail NotImplementedError
        end

        # @return [String] what message should be printed when error occures
        # @note By default the whole output of an executed command will be printed
        def error_message
          output
        end

        private

        # Checks if a framework is required for a given command, and if so, it wont
        # allow to execute this command if it is not present
        # @raise [PolishGeeks::DevTools::Command::Base::MissingFramework] if req framework missing
        def ensure_framework_if_required
          return unless self.class.framework
          return if PolishGeeks::DevTools.config.public_send(:"#{self.class.framework}?")

          fail MissingFramework, self.class.framework
        end
      end
    end
  end
end
