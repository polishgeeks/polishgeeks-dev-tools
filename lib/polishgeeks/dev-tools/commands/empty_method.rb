module PolishGeeks
  module DevTools
    module Commands
      # Validator used to check if all '.rb' files don't have empty methods
      class EmptyMethod < Base
        self.type = :validator

        attr_reader :counter

        # Default paths which we want to exclude from analyse
        DEFAULT_PATHS_TO_EXCLUDE = %w(
          coverage
          tmp
          doc
          log
          vendor
          public
          app/assets/images
          app/assets/fonts
        )

        # Executes this command and set output and counter variables
        def execute
          @output = []
          @counter = 0

          files_to_analyze.each do |file|
            @counter += 1
            empty_methods = FileParser.new(file).find_empty_methods
            @output << sanitize(file) + " lines #{empty_methods}" unless empty_methods.empty?
          end
        end

        # @return [Boolean] true if none of the files include any empty methods
        def valid?
          output.empty?
        end

        # @return [String] default label for this command
        def label
          "Empty methods: #{counter} files checked"
        end

        # @return [String] message that should be printed when some files have
        # empty methods
        def error_message
          "Following files contains blank methods: \n#{output.join("\n")}\n"
        end

        private

        # @return [Array<String>] array with files to analyze
        # @note method take all not excluded files
        def files_to_analyze
          files = files_from_path('**/*.rb')
          remove_excludes files
        end

        # @param [Array<String>] files list which we want analyse
        # @return [Array<String>] array without excluded files
        def remove_excludes(files)
          excluded_paths = excludes

          files.delete_if do |file|
            excluded_paths.any? { |exclude| file =~ /#{exclude}/ }
          end
        end

        # @return [Array<String>] list of files/directories that
        #   should be excluded from checking
        # @note excluded files/directories are defined in DEFAULT_PATHS_TO_EXCLUDE
        #   and in configuration file
        def excludes
          config_excludes + DEFAULT_PATHS_TO_EXCLUDE
        end

        # @return [Array<String>] list of excluded files/directories from config file
        def config_excludes
          DevTools.config.empty_method_ignored || []
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
