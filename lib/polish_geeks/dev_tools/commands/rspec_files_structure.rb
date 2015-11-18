module PolishGeeks
  module DevTools
    module Commands
      # Checks if there are are rb files that don't have corresponding rspec
      # spec files defined
      # This will validate that the names are the same (no typos, etc) and no
      # file are without spec files (even just with pending)
      class RspecFilesStructure < Base
        self.type = :validator

        # Files in directories that we want to check against their rspec
        # corresponding files
        FILES_CHECKED = %w(
          app/**/*.rb
          lib/**/*.rb
        )

        # From where should we take spec files
        RSPEC_FILES = %w(
          spec/**/*_spec.rb
        )

        # Executes this command
        # @return [Array<String>] empty array if all the files have corresponding
        #   rspec files, otherwise array will contain files that doesn't
        def execute
          @output = {
            app: analyzed_files - rspec_files,
            rspec: rspec_files - analyzed_files
          }
        end

        # @return [Boolean] true if everything is ok and all the files have
        #   rspec corresponding files
        def valid?
          @output[:app].empty? && @output[:rspec].empty?
        end

        # @return [String] label with this validator description
        def label
          "Rspec files structure (#{analyzed_files.count} checked)"
        end

        # @return [String] error message that will be displayed if something
        #   goes wrong
        def error_message
          err = files_error_message + rspec_error_message
          err
        end

        private

        # @return [Array<String>] array with list of files that we want to compare with
        #   those from Rspec that should exist
        def analyzed_files
          files = FILES_CHECKED.map do |dir|
            Dir[File.join(DevTools.app_root, dir)]
          end

          files.flatten!
          files.uniq!

          files.delete_if do |file|
            excludes.any? { |exclude| file.include?(exclude) }
          end

          files.map! { |file| sanitize(file) }

          files
        end

        # @return [Array<String>] rspec files that should correspond with analyzed_files
        def rspec_files
          files = RSPEC_FILES.map { |dir| Dir[File.join(DevTools.app_root, dir)] }

          files.flatten!

          files.delete_if do |file|
            excludes.any? { |exclude| file =~ /#{exclude}/ }
          end

          files.map! { |file| sanitize(file) }
          files.uniq!

          files
        end

        # @param [String] file name that we want to sanitize
        # @return [String] sanitized file name
        # @example
        #   file = /home/something/app/models/user.rb
        #   sanitize(file) #=> models/user.rb
        def sanitize(file)
          file.gsub!(DevTools.app_root + '/', '')
          file.gsub!('_spec.rb', '.rb')
          file.gsub!('spec/', '')
          file.gsub!('app/', '')
          file
        end

        # @return [String] return message with files which don't
        # have corresponding Rspec files
        def files_error_message
          return '' if @output[:app].empty?
          err = 'Following files don\'t have corresponding Rspec files:'
          err << "\n\n"
          err << @output[:app].join("\n")
          err << "\n"
          err
        end

        # @return [String] return message with Rspec files which don't
        # have corresponding files
        def rspec_error_message
          return '' if @output[:rspec].empty?
          err = "\n\n"
          err << 'Following Rspec don\'t have corresponding files:'
          err << "\n\n"
          err << @output[:rspec].map! { |file| file.gsub!('.rb', '_spec.rb') }.join("\n")
          err << "\n"
          err
        end

        # @return [Array<String>] list of files/directories that
        #   should be excluded from checking
        # @note This should be set in the initializer for this gem
        #   in the place where it is going to be used
        def excludes
          DevTools.config.rspec_files_structure_ignored || []
        end
      end
    end
  end
end
