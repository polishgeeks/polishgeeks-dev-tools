module PolishGeeks
  module DevTools
    module Commands
      # Checks for required files
      class RequiredFiles < Base
        self.type = :validator

        # Executes this command
        # @return [String] command output
        def execute
          output = []
          required_files = ['README.md']
          required_files.concat(::PolishGeeks::DevTools.config.required_files_include || [])
          required_files.each do |required_file|
            file_path = File.join(::PolishGeeks::DevTools.app_root, required_file)
            output << "#{file_path} not exist" unless File.exist?(file_path)
            output << "#{file_path} is empty" if File.zero?(file_path)
          end
          @output = output
        end

        # @return [String] error message
        def error_message
          return if @output.nil?
          err = 'Following files does not exist or are empty:'
          err << "\n"
          err << @output.join("\n")
          err << "\n"
        end

        # @return [Boolean] true if files exist and are not empty
        def valid?
          @output.empty?
        end
      end
    end
  end
end
