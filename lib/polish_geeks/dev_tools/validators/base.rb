module PolishGeeks
  module DevTools
    # Module encapsulating all the validators that we use to check/verify code
    module Validators
      # Base class for all the validators
      # @abstract Subclass and use
      class Base
        def initialize(stored_output)
          @stored_output = stored_output
        end

        # This should be implemented in a subclass
        # @return [Boolean] if validation check is valid or not
        def valid?
          raise Errors::NotImplementedError
        end

        # @raise [PreCommandValidationError] when valid? return false
        # @return [Boolean] if validation check is valid or not
        def validate!
          raise Errors::PreCommandValidationError unless valid?
        end
      end
    end
  end
end
