module PolishGeeks
  module DevTools
    module Command
      # Validator used to check if all files have final blank line
      class FinalBlankLine < Base
        self.type = :validator

        attr_reader :counter

        # Executes this command
        # @return [Array] command output array with list of files
        #   that don't have final blank line
        def execute
          @output = []

          # @todo: change it to whole files
          # add excludes directories (yardoc, coverage, tmp, images....)
          path = PolishGeeks::DevTools.app_root + '/lib'
          files = Dir.glob("#{path}/**/*").select { |f| File.file? f }
          @counter = files.count

          files.each do |file|
            @output << file unless IO.readlines(file).last[-1] == "\n"
          end
        end

        # @return [Boolean] true if files have final blank line
        def valid?
          output.empty?
        end

        # @return [String] default label for this command
        def label
          "Final blank line checker: #{counter} files checked"
        end

        # @return [String] message that should be printed when some files don't have
        # final blank line
        def error_message
          "Following files don't have final blank line: \n#{output.join("\n")}\n"
        end
      end
    end
  end
end
