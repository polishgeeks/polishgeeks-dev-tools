module PolishGeeks
  module DevTools
    module Commands
      class EmptyMethods
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
      end
    end
  end
end
