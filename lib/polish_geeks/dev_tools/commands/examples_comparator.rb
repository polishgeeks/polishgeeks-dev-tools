module PolishGeeks
  module DevTools
    module Commands
      # Command wrapper for ExamplesComparator rake task
      # It informs us if our .example files structure is the same as non-example once
      class ExamplesComparator < Base
        self.type = :validator

        # Executes this command
        # @return [String] command output
        def execute
          @output = "Comparing yaml structure of example files\n\n"

          Dir[config_path].each do |example_file|
            dedicated_file = example_file.gsub('.example', '')
            header = compare_header(example_file, dedicated_file)
            @output << compare_output(header, example_file, dedicated_file)
          end
        end

        # @return [Boolean] true if all the example files have the same structure
        #   as non-example once, false otherwise
        def valid?
          !output.include?('failed')
        end

        private

        # @return [String] config path with all the yml.example files included
        # @note This method is used in Dir[] to get all the example files
        def config_path
          "#{File.expand_path(PolishGeeks::DevTools.app_root + '/config')}/**/*.yml.example"
        end

        # @param [File] example_file which we compare with dedicated one
        # @param [File] dedicated_file which is compared with example one
        # @return [Hash] none empty hash if the key structure is different
        #  in compared files, empty hash otherwise
        def keys_difference(example_file, dedicated_file)
          yaml1 = PolishGeeks::DevTools::Hash.new
          yaml1.merge!(YAML.load_file(example_file))
          yaml2 = PolishGeeks::DevTools::Hash.new
          yaml2.merge!(YAML.load_file(dedicated_file))

          yaml1.diff(yaml2)
        end

        # @param [File] example_file which we compare with dedicated one
        # @param [File] dedicated_file which is compared with example one
        # @return [String] success/failure (both) message header
        def compare_header(example_file, dedicated_file)
          "#{File.basename(example_file)} and #{File.basename(dedicated_file)}"
        end

        # @param [String] header output message
        # @param [File] example_file which we compare with dedicated one
        # @param [File] dedicated_file which is compared with example one
        # @return [String] success/failure message for single file
        def compare_output(header, example_file, dedicated_file)
          difference = keys_difference(example_file, dedicated_file)
          if difference.empty?
            successful_compare(header)
          else
            failed_compare(header, difference)
          end
        end

        # @param [String] compare_header output message
        # @return [String] success message for single file
        def successful_compare(compare_header)
          "\e[32m success\e[0m - #{compare_header}\n"
        end

        # @param [String] compare_header output message
        # @return [String] failed message for single file
        def failed_compare(compare_header, details = '')
          structure_diff = details.to_yaml.gsub("\n", "\n\t")
          "\e[31m failed\e[0m - #{compare_header}" \
          " - structure not equal:\n\t#{structure_diff}\n"
        end
      end
    end
  end
end
