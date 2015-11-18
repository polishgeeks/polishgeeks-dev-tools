module PolishGeeks
  module DevTools
    module Validators
      # It verifies if Rails is available
      class Rails < Base
        def valid?
          Object.const_defined?('Rails')
        end
      end
    end
  end
end
