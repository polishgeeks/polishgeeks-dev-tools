module PolishGeeks
  module DevTools
    module Command
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
            empty_methods = PolishGeeks::DevTools::FileParser.new(file).find_empty_methods
            @output << sanitize(file) + " lines #{empty_methods}" unless empty_methods.empty?
          end
        end

        # @return [Boolean] true if all files don't have empty methods
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

    # Adds ability to check strings on specific regex matching
    module StringRefinements
      # Regex to determine commented or empty string
      COMMENTED_OR_EMPTY = /^\s*(|#.*)$/
      # Regex to determine definition of method with 'def'
      DEFINITION_OF_METHOD = /^\s*def\s+\w*(\s*|\s*#.*)$/
      # Regex to determine empty one-line method
      EMPTY_ONE_LINE_METHOD = /^\s*def\s+.*;\s*end\s*(\s+|#.*|\n|$)$/
      # Regex to determine end of method
      END_REGEX = /^\s*end(\.\w+(\s+|$)|\s*#.+|\s+|$)\s*/
      # Regex to determine begin of method definition through define_method
      DEFINE_METHOD = '^\s*(define_method|define_singleton_method)'
      # Regex to determine definition of method with do-end block
      DEFINE_METHOD_WITH_DO_END =
        /#{DEFINE_METHOD}(\s+|\().*do(\s*(\s*|.*\|\s*))(\s*|#.*)$/
      # Regex to determine empty one-line methods
      EMPTY_ONE_LINE_DEFINE_METHODS =
        /#{DEFINE_METHOD}.+\s+({\s*)\s*((\|.*\|\s+})|})(\s+|\n|#|$|\.)/

      refine String do
        def one_line_empty_method?
          match(EMPTY_ONE_LINE_METHOD) || match(EMPTY_ONE_LINE_DEFINE_METHODS)
        end

        def defines_method?
          match(DEFINITION_OF_METHOD) || match(DEFINE_METHOD_WITH_DO_END)
        end

        def defines_end?
          match END_REGEX
        end

        def not_commented_or_empty?
          match(COMMENTED_OR_EMPTY).nil?
        end
      end
    end

    # Parse file and search whether it contain empty methods
    class FileParser
      attr_reader :empty_methods
      using StringRefinements

      def initialize(file)
        @file = IO.readlines(file)
        @empty_methods = []
      end

      # @return [Array<Fixnum>] list of lines where empty methods are defined
      # @example
      #   file = " class Example
      #     def empty_method; end
      #   end
      #   "
      #   FileParser.new(file).find_empty_methods => [2]
      #
      #   file = ""
      #   FileParser.new(file).find_empty_methods => []
      def find_empty_methods
        @file.each_with_index do |line, index|
          next add_empty_method(index) if line.one_line_empty_method?
          check_bodies_existence(line, index)
        end
        empty_methods
      end

      private

      # Adds line of empty method definition to array of empty_methods
      # Remembers line where method is defined; search end of method definition
      # and check whether body of method is empty or not.
      # @param [String] line line to parse for empty methods definition
      # @param [Fixnum] index index of line in file
      def check_bodies_existence(line, index)
        @method_definition_line = index if line.defines_method?
        return unless @method_definition_line && line.defines_end?

        if method_has_no_lines?(@method_definition_line, index)
          return add_empty_method(@method_definition_line)
        end

        body_lines = (@method_definition_line + 1)..(index - 1)
        method_body = @file[body_lines]

        add_empty_method(@method_definition_line) if method_is_empty?(method_body)
        @method_definition_line = nil
      end

      # @param [Array<String>] method_body
      # @return [Boolean] whether method is empty or not
      def method_is_empty?(method_body)
        !method_body.inject(false) { |a, e| a || e.not_commented_or_empty? }
      end

      # Adds line number of empty method to empty_methods.
      # @param [Fixnum] index index of line
      def add_empty_method(index)
        empty_methods << index + 1
      end

      def method_has_no_lines?(body_begin, body_end)
        body_end - body_begin < 2
      end
    end
  end
end
