module PolishGeeks
  module DevTools
    # Module encapsulating all the commands that we use to check/verify code
    module Commands
      # Base class for all the commands
      # @abstract Subclass and use
      class Base
        # Output string that we get after executing this command
        attr_reader :output
        # stored_output [PolishGeeks::DevTools::OutputStorer] storer with results of previous
        #   commands (they might use output from previous/other commands)
        attr_accessor :stored_output

        # Available command types. We have validators that check something
        # and that should have a 'valid?' method and that check for errors, etc
        # and generators that are executed to generate some stats, docs, etc
        TYPES = %i( validator generator )

        class << self
          attr_accessor :config_name
          attr_accessor :type
          attr_accessor :validators

          TYPES.each do |type|
            # @return [Boolean] if it is a given type command
            define_method :"#{type}?" do
              self.type == type
            end
          end
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        def execute
          fail Errors::NotImplementedError
        end

        # @raise [NotImplementedError] this should be implemented in a subclass
        #   if it is a validator type (or no implementation required when
        #   it is a validator)
        def valid?
          fail Errors::NotImplementedError
        end

        # @return [String] what message should be printed when error occures
        # @note By default the whole output of an executed command will be printed
        def error_message
          output
        end

        # Runs validators if any to check if all requirements of this command
        # are met in order to execute it properly
        # @raise [PolishGeeks::DevTools::Errors::InvalidValidatorClassError] when invalid
        #   validator class name is defined
        # @raise [PolishGeeks::DevTools::Errors::PreCommandValidationError] when validator
        #   conditions are not met
        def ensure_executable!
          (self.class.validators || []).each do |validator_class|
            validator_class.new(stored_output).validate!
          end
        end

        # @return [Boolean] if there is a config present
        def config?
          app_config? || local_config?
        end

        # @return [String] path to config file
        def config
          app_config? ? app_config : local_config
        end

        private

        # @param [String] path from which we want take files
        # @return [Array<String>] list of files in path with app prefix path
        # @note if path is a file return array with file path with app prefix path
        def files_from_path(path)
          full_path = "#{::PolishGeeks::DevTools.app_root}/#{path}"
          return [full_path] if File.file?(full_path)

          Dir.glob(full_path).select { |f| File.file? f }
        end

        # @return [Boolean] if there is a config present locally
        def local_config?
          !self.class.config_name.nil? && File.exist?(local_config)
        end

        # @return [String] path to local config file
        def local_config
          File.join(DevTools.gem_root, 'config', self.class.config_name)
        end

        # @return [Boolean] if there is a config present in the application
        def app_config?
          !self.class.config_name.nil? && File.exist?(app_config)
        end

        # @return [String] path to application config file
        def app_config
          File.join(DevTools.app_root, self.class.config_name)
        end
      end
    end
  end
end
