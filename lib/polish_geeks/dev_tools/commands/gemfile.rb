module PolishGeeks
  module DevTools
    module Commands
      # Checks if Gemfile contains local gems
      class Gemfile < Base
        self.type = :validator

        # Regex which check if Gemfile has local gem
        # ex:
        #   gem 'example_gem', path: '/Users/Projects/gems/example_gem'
        #   gem 'example_gem', :path => '/Users/Projects/gems/example_gem'
        CHECKED_REGEXP = /^[^#]*((\bpath:)|(:path[ \t]*=>))/

        # Executes this command
        def execute
          @output = []
          gemfile = File.join(::PolishGeeks::DevTools.app_root, 'Gemfile')
          return unless File.exist?(gemfile)
          @output = IO.readlines(gemfile).select { |l| l.match(CHECKED_REGEXP) }
        end

        # @return [String] label with this validator description
        def label
          'Gemfile checking'
        end

        # @return [String] message with local gems
        def error_message
          "Gemfile contains gems from local path: \n#{output.join('')}"
        end

        # @return [Boolean] true if output doesn't contain any local gems
        def valid?
          @output.empty?
        end
      end
    end
  end
end
