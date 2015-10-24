module PolishGeeks
  module DevTools
    module Commands
      # Verifying parameters in example YAML config files
      class YmlParser < Base
        self.type = :validator

        # Executes this command
        # @return [Array] command output
        def execute
          @output = []
          Dir[config_path].each do |file|
            parsed_file = parse_yaml(file)
            nil_params = check_params(parsed_file)
            next if nil_params.empty?
            @output << {
              file: file,
              lines: nil_params
            }
          end

          @output
        end

        # @return [String] label with this validator description
        def label
          'Yaml parser'
        end

        # @return [String] error message
        def error_message
          err = 'Following yml files have nil as a value:'
          @output.each { |row| err << file_error(row) }
          err << "\n"
        end

        # @return [Boolean] true if all parameters in YAML files
        # have not nil value
        def valid?
          @output.empty?
        end

        private

        # @return [String] error message with file name and parameters which have nil value
        def file_error(err_message)
          err = "\n#{sanitize(err_message[:file])}:"
          err_message[:lines].each { |line| err << "\n - Key '#{line}'" }
          err
        end

        # @return [String] config path with all yaml files
        def config_path
          "#{File.expand_path(PolishGeeks::DevTools.app_root + '/config')}/**/*.yml.example"
        end

        # @param [String] file name that we want to sanitize
        # @return [String] sanitized file name
        # @example
        #   file = /home/something/app/condig/settings.rb
        #   sanitize(file) #=> settings.rb
        def sanitize(file)
          file.gsub!(PolishGeeks::DevTools.app_root + '/config/', '')
          file
        end

        # @param [String] file name that we want to load
        # @return [Hash] data serialization in YAML format
        def parse_yaml(file)
          YAML.load(File.open(file))
        end

        # recursion method to find key with nil value
        # @param [Hash] hash which we want to check
        # @return [Array] parameters with nil value
        def check_params(hash)
          hash.map do |k, v|
            return k if v.nil?
            check_params(v) if v.is_a?(::Hash)
          end.compact.flatten
        end
      end
    end
  end
end
