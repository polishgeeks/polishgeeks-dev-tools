require 'ostruct'

module PolishGeeks
  module DevTools
    # Class used to store output from every executed command
    # We store this data because it might be used by other commands
    class OutputStorer < OpenStruct
      # Creates a result storer instance
      def initialize
        init = {}
        Config::COMMANDS.each { |command| init[command] = '' }

        super(init)
      end
    end
  end
end
