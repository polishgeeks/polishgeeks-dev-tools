module PolishGeeks
  module DevTools
    # Module that encapsulates all the DevTools errrors
    module Errors
      # Base class for all DevTools errors
      class BaseError < StandardError; end

      # Raised when we specify a framework in which a given command can be executed
      # and it is not present (not detected)
      class MissingFramework < BaseError; end

      # Raised when we want to run method that was not implemented and we have just a stub
      # from parent class
      class NotImplementedError < BaseError; end
    end
  end
end
