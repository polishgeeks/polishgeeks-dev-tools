module PolishGeeks
  module DevTools
    module Commands
      # Checking config directory that all files are allowed
      class AllowedExtensions < Base
        self.type = :validator

        # List of allowed extensions of files
        ALLOWED_EXTENSIONS = %w(
          rb
          yml
          rb.example
          yml.example
        )

        # Executes this command
        # @return [Array] command output array with list of
        # not allowed files in config directory
        def execute
          results = Dir[config_path]

          @output = results
            .flatten
            .map { |line| line.gsub!(PolishGeeks::DevTools.app_root + '/config/', '') }
            .uniq
          @output.delete_if do |line|
            ALLOWED_EXTENSIONS.any? { |allow| line =~ /^.*\.#{allow}$/i }
          end

          @output
        end

        # @return [String] label with this validator description
        def label
          'Allowed Extensions'
        end

        # @return [String] error message that will be displayed if something
        #   goes wrong
        def error_message
          err = 'Following files are not allowed in config directory:'
          err << "\n\n"
          err << @output.join("\n")
          err << "\n"
        end

        # @return [Boolean] true if all files in config directory
        # have correct extension
        def valid?
          @output.empty?
        end

        private

        # @return [String] config path with all files included
        def config_path
          "#{File.expand_path(PolishGeeks::DevTools.app_root + '/config')}/*.*"
        end
      end
    end
  end
end
