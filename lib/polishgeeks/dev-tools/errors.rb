module PolishGeeks
  module DevTools
    # Module that encapsulates all the DevTools errrors
    module Errors
      # Base class for all DevTools errors
      class BaseError < StandardError; end

      # Raised when we want to run method that was not implemented and we have just a stub
      # from parent class
      class NotImplementedError < BaseError; end

      # Raised when we want to run an command for which pre validation does not pass
      class PreCommandValidationError < StandardError; end

      # Raised when invalid validator class name passed
      class InvalidValidatorClassError < StandardError; end

      # Raised when validators are defined with an unsupported type
      class InvalidValidatorsTypeError < StandardError; end
    end
  end
end
