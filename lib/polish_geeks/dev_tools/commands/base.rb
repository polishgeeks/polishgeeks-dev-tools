module PolishGeeks
  module DevTools
    # Module encapsulating all the commands that we use to check/verify code
    module Commands
      # Base class for all the commands
      # @abstract Subclass and use
      class Base
        include PolishGeeks::DevTools::Helpers::FileHelper

        # Output string that we get after executing this command
        attr_reader :output
        # stored_output [PolishGeeks::DevTools::OutputStorer] storer with results of previous
        #   commands (they might use output from previous/other commands)
        attr_accessor :stored_output

        # Available command types. We have validators that check something
        # and that should have a 'valid?' method and that check for errors, etc
        # and generators that are executed to generate some stats, docs, etc
        TYPES = %i( validator generator ).freeze

        class << self
          # ConfigManager instance can be provided, which allows us to find a
          # config file for a command
          attr_accessor :config_manager
          attr_accessor :type
          attr_accessor :validators

          TYPES.each do |type|
            # @return [Boolean] if it is a given type command
            define_method :"#{type}?" do
              self.type == type
            end
          end
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        def execute
          raise Errors::NotImplementedError
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        #   if it is a validator type (or no implementation required when
        #   it is a validator)
        def valid?
          raise Errors::NotImplementedError
        end

        # @return [String] what message should be printed when error occures
        # @note By default the whole output of an executed command will be printed
        def error_message
          output
        end

        # Runs validators if any to check if all requirements of this command
        # are met in order to execute it properly
        # @raise [PolishGeeks::DevTools::Errors::InvalidValidatorClassError] when invalid
        #   validator class name is defined
        # @raise [PolishGeeks::DevTools::Errors::PreCommandValidationError] when validator
        #   conditions are not met
        def ensure_executable!
          (self.class.validators || []).each do |validator_class|
            validator_class.new(stored_output).validate!
          end
        end
      end
    end
  end
end
