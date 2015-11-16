module PolishGeeks
  module DevTools
    module Commands
      # Validator used to check if all the rspec spec files have a proper
      # sufix (_spec.rb)
      class RspecFilesNames < Base
        self.type = :validator

        attr_reader :counter

        # List of dirs in spec/ dir that we will check for
        # _spec.rb naming
        CHECKED_DIRS = %w(
          aggregators controllers helpers lib libs models decorators
          presenters services workers mailers requests polishgeeks*
        )

        # Regexp used to check names in spec files
        CHECK_REGEXP = /(\_spec\.rb)$/

        # Executes this command
        # @return [Array] command output array with list of spec files
        #   that dont have a proper name
        def execute
          @output = []
          @counter = 0

          CHECKED_DIRS.each do |name|
            path = File.join(::PolishGeeks::DevTools.app_root, 'spec', name)
            files = Dir.glob("#{path}/**/*").select { |f| File.file? f }

            @counter += files.count

            files.each do |file|
              @output << file unless file =~ CHECK_REGEXP
            end
          end
        end

        # @return [Boolean] true if all specs have a proper sufix (_spec.rb)
        def valid?
          output.empty?
        end

        # @return [String] default label for this command
        def label
          "Rspec files names: #{counter} files checked"
        end

        # @return [String] message that should be printed when some files have
        #   invalid name
        def error_message
          "Following files have invalid name: \n #{output.join("\n")}\n"
        end
      end
    end
  end
end
