module PolishGeeks
  module DevTools
    module Validators
      # It verifies if Rubocop is enabled
      class Rubocop < Base
        def valid?
          PolishGeeks::DevTools.config.rubocop == true
        end
      end
    end
  end
end
