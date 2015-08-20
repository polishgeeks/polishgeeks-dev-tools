module PolishGeeks
  module DevTools
    module Command
      # Validator used to check if all files have final blank line
      class FinalBlankLine < Base
        self.type = :validator

        attr_reader :counter

        # Default paths which we want to exclude from analyse
        DEFAULT_PATHS_TO_EXCLUDE = %w(
          coverage
          tmp
          log
          public
          app/assets/images
          app/assets/fonts
        )

        # Executes this command
        # @return [Array] command output array with list of files
        #   that don't have final blank line
        def execute
          @output = []
          @counter = 0

          files_to_analyze.each do |file|
            @counter += 1
            @output << file if File.size(file) > 0 && IO.readlines(file).last[-1] != "\n"
          end
        end

        # @return [Boolean] true if files have final blank line
        def valid?
          output.empty?
        end

        # @return [String] default label for this command
        def label
          "Final blank line: #{counter} files checked"
        end

        # @return [String] message that should be printed when some files don't have
        # final blank line
        def error_message
          "Following files don't have final blank line: \n#{output.join("\n")}\n"
        end

        private

        # @return [Array<String>] array with files to analyze
        def files_to_analyze
          # expression {*,.*} is needed because glob method don't take unix-like hidden files
          files_from_path('**/{*,.*}') - excludes
        end

        # @return [Array<String>] list of files that
        #   should be excluded from checking
        def excludes
          (default_excludes + config_excludes).flatten
        end

        # @return [Array<String>] list of default excluded files
        def default_excludes
          excluded_files = []
          DEFAULT_PATHS_TO_EXCLUDE.each do |path|
            excluded_files << files_from_path("#{path}/**/{*,.*}")
          end
          excluded_files
        end

        # @return [Array<String>] list of excluded files from config
        def config_excludes
          excluded_files = []
          config_paths = DevTools.config.final_blank_line_in_files_ignored
          return [] unless config_paths

          config_paths.each do |path|
            excluded_files << (File.file?(path) ? path : files_from_path(path))
          end

          excluded_files
        end

        # @param [String] path from which we want take files
        # @return [Array<String>] list of files in path
        def files_from_path(path)
          Dir.glob(path).select { |f| File.file? f }
        end
      end
    end
  end
end
