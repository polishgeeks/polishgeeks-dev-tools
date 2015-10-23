module PolishGeeks
  module DevTools
    # Module encapsulating all the commands that we use to check/verify code
    module Command
      # Base class for all the commands
      # @abstract Subclass and use
      class Base
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
          attr_accessor :validators
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
          self.class.validators ||= []
          prepare_validators
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        def execute
          fail Errors::NotImplementedError
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        #   if it is a validator type (or no implementation required when
        #   it is a validator)
        def valid?
          fail Errors::NotImplementedError
        end

        # @return [String] what message should be printed when error occures
        # @note By default the whole output of an executed command will be printed
        def error_message
          output
        end

        # Runs validators if any to check if all requirements of this command
        # are met in order to execute it properly
        # @raise [InvalidValidatorClassError] when invalid validator class name is defined
        # @raise [PreCommandValidationError] when validator conditions are not met
        def validation!
          self.class.validators.each do |name|
            fail Errors::InvalidValidatorClassError unless validator_class?(name)
            validator_class(name).new(stored_output).validate!
          end
        end

        private

        # Checks if validator class constant is defined
        # @param name [String] validator class name
        # @return [Boolean]
        def validator_class?(name)
          Object.const_defined?("PolishGeeks::DevTools::Validators::#{name}")
        end

        # Returns validator class as a constant
        # @param name [String] validator class name
        # @return [Class] validator class constant
        def validator_class(name)
          Object.const_get("PolishGeeks::DevTools::Validators::#{name}")
        end

        # Checks if we can add default validator
        # This will only happen if no validators are defined in the command directly
        # @return [Boolean]
        def default_validator?
          self.class.validators.empty? && validator_class?(class_name)
        end

        # Add default validator if possible
        def default_validator
          self.class.validators.push(class_name) if default_validator?
        end

        # Verify if validators are correctly prepared, add default validator if
        # possible
        def prepare_validators
          fail Errors::InvalidValidatorsTypeError unless self.class.validators.instance_of?(Array)
          default_validator
        end

        # Returns not scoped current class name
        # @return [String] current class name
        def class_name
          self.class.name.split('::').last
        end
      end
    end
  end
end
