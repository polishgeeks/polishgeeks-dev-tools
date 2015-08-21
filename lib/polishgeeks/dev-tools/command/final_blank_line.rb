module PolishGeeks
  module DevTools
    module Command
      # Validator used to check if all files have final blank line
      class FinalBlankLine < Base
        self.type = :validator

        attr_reader :counter

        # Default paths which we want to exclude from analyse
        DEFAULT_PATHS_TO_EXCLUDE = %w(
          coverage tmp log vendor public
          app/assets/images
          app/assets/fonts
        )

        # Executes this command and set output and counter variables
        def execute
          @output = []
          @counter = 0

          files_to_analyze.each do |file|
            @counter += 1
            @output << sanitize(file) if File.size(file) > 0 && IO.readlines(file).last[-1] != "\n"
          end
        end

        # @return [Boolean] true if all files have final blank line
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
        #   defined in DEFAULT_PATHS_TO_EXCLUDE
        def default_excludes
          excluded_files = []

          DEFAULT_PATHS_TO_EXCLUDE.each do |path|
            excluded_files << files_from_path("#{path}/**/{*,.*}")
          end

          excluded_files
        end

        # @return [Array<String>] list of excluded files from config file
        def config_excludes
          excluded_files = []
          config_paths = DevTools.config.final_blank_line_ignored
          return [] unless config_paths

          config_paths.each do |path|
            excluded_files << files_from_path(path)
          end

          excluded_files
        end

        # @param [String] path from which we want take files
        # @return [Array<String>] list of files in path with app prefix path
        # @note if path is a file return array with file path with app prefix path
        def files_from_path(path)
          full_path = "#{::PolishGeeks::DevTools.app_root}/#{path}"
          return [full_path] if File.file?(full_path)

          Dir.glob(full_path).select { |f| File.file? f }
        end

        # @param [String] file name that we want to sanitize
        # @return [String] sanitized file name
        # @example
        #   file = /home/something/app/lib/lib.rb,
        #   where /home/something/app/ is a app root path, then
        #   sanitize(file) #=> lib/lib.rb
        def sanitize(file)
          file.gsub("#{PolishGeeks::DevTools.app_root}/", '')
        end
      end
    end
  end
end
