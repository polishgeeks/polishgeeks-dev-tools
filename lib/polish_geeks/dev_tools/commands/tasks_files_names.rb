module PolishGeeks
  module DevTools
    module Commands
      # Checks if tasks files (rake and capistrano) have proper extensions
      class TasksFilesNames < Base
        self.type = :validator

        attr_reader :counter

        # Capistrano tasks check rules
        CAP = OpenStruct.new(
          dirs: %w(
            lib/capistrano
          ),
          regexp: /.*\.cap$/
        )

        # Rake tasks check rules
        RAKE = OpenStruct.new(
          dirs: %w(
            lib/tasks
          ),
          regexp: /.*\.rake$/
        )

        # Executes this command
        # @return [Array<String>] command output array with list of spec files
        #   that dont have a proper name, or an empty array if everything is ok
        def execute
          @output = []
          @counter = 0

          cap_files = files(CAP)
          @counter += cap_files.count

          cap_files.delete_if { |file| file =~ CAP.regexp }
          @output += cap_files

          rake_files = files(RAKE)
          @counter += rake_files.count

          rake_files.delete_if { |file| file =~ RAKE.regexp }
          @output += rake_files
        end

        # @return [Boolean] true if all files have proper names and extensions
        def valid?
          output.empty?
        end

        # @return [String] default label for this command
        def label
          "Tasks files names: #{counter} files checked"
        end

        # @return [String] message that should be printed when some files have
        #   invalid extensions/names
        def error_message
          "Following files have invalid extensions: \n #{output.join("\n")}\n"
        end

        private

        # @param type [OpenStruct] openstruct with a dirs and regexp methods
        # @return [Array<String>] Array with all the files of appropriate type
        def files(type)
          files = type.dirs.map { |dir| Dir["#{DevTools.app_root}/#{dir}/**/*"] }
          files.flatten!
          files.delete_if { |file| File.directory?(file) }

          files
        end
      end
    end
  end
end
