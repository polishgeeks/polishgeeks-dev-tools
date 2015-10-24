module PolishGeeks
  module DevTools
    module Commands
      # Checking Rails cache options especially expires_in
      class ExpiresIn < Base
        self.type = :validator

        # List of dirs that we will check for
        CHECKED_DIRS = %w(
          app
          lib
        )

        # Regexp that we want to use to catch invalid things that occur
        # instead of expires_in
        CHECKED_REGEXP = 'expire_in\|expir_in'

        # Executes this command
        def execute
          results = CHECKED_DIRS.map do |directory|
            path = File.join(PolishGeeks::DevTools.app_root, directory)
            shell_command(path).split("\n")
          end

          @output = results
            .flatten
            .map { |line| line.split(':').first }
            .map { |line| line.gsub!(PolishGeeks::DevTools.app_root, '') }
            .uniq

          @output.delete_if do |line|
            excludes.any? { |exclude| line =~ /#{exclude}/ }
          end
        end

        # @return [String] label with this validator description
        def label
          'Expires in'
        end

        # @return [String] error message
        def error_message
          err = 'Following files use expire_in instead of expires_in:'
          err << "\n\n"
          err << @output.join("\n")
          err << "\n"
        end

        # @return [Boolean] true if not find expire_in
        def valid?
          @output.empty?
        end

        # @return [Array<String>] list of files/directories that should be excluded from checking
        # @note This should be set in the initializer for this gem in the
        #   place where it is going to be used
        def excludes
          DevTools.config.expires_in_files_ignored || []
        end

        private

        # @param [String] path in which we want to search
        # @return [String] grep command that should be executed
        #   to find what we search for
        # @note Not every path must exist, thats why we redirect errors to /dev/null, that way
        # we can skip all the errors
        def shell_command(path)
          `grep -R \"#{CHECKED_REGEXP}\" #{path}/* 2>/dev/null`
        end
      end
    end
  end
end
