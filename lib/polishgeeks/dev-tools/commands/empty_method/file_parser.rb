module PolishGeeks
  module DevTools
    module Commands
      class EmptyMethod
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
  end
end
