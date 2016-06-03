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
            if File.exist?(dedicated_file)
              header = compare_header(example_file, dedicated_file)
              @output << compare_output(header, example_file, dedicated_file)
            else
              @output << missing_file(dedicated_file)
            end
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
        # @return [Boolean] true if the key structure is the same in both files
        #   otherwise false
        def same_key_structure?(example_file, dedicated_file)
          yaml1 = PolishGeeks::DevTools::Hash.new
          yaml1.merge!(YAML.load_file(example_file))
          yaml2 = PolishGeeks::DevTools::Hash.new
          yaml2.merge!(YAML.load_file(dedicated_file))

          yaml1.same_key_structure?(yaml2)
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
          if same_key_structure?(example_file, dedicated_file)
            successful_compare(header)
          else
            failed_compare(header)
          end
        end

        # @param [String] compare_header output message
        # @return [String] success message for single file
        def successful_compare(compare_header)
          "\e[32m success\e[0m - #{compare_header}\n"
        end

        # @param [String] compare_header output message
        # @return [String] failed message for single file
        def failed_compare(compare_header)
          "\e[31m failed\e[0m - #{compare_header} - structure not equal\n"
        end

        # @param [String] dedicated_file path to config file which is missing
        # @return [String] failed message for missing file
        def missing_file(dedicated_file)
          "\e[31m failed\e[0m - #{File.basename(dedicated_file)} - file is missing\n"
        end
      end
    end
  end
end
