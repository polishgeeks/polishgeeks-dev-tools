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
      class PreCommandValidationError < BaseError; end

      # Raised when validators are defined with an unsupported type
      class InvalidValidatorsTypeError < BaseError; end

      # Raised when it is a type of task that we don't recognize
      class UnknownTaskType < BaseError; end

      # Raised when any of tasks fail
      class RequirementsError < BaseError; end
    end
  end
end
