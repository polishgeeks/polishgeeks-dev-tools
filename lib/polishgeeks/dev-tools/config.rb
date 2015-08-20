module PolishGeeks
  module DevTools
    # Configurator for enabling specific command runners
    # @note No commands are enabled by default
    # @example Enable only rubocop
    # Config.configure do |conf|
    #   conf.rubocop = true
    # end
    class Config
      class << self
        attr_accessor :config

        # @return [PolishGeeks::DevTools::Config] config for dev tools
        # @note We check if it initialized, because if user wants to use it
        #   with all the commands enabled and without any changes, he won't create
        #   a polishgeeks_dev_tools.rb initializer file so we need to configure it
        #   with defaults
        def config
          @config || setup {}
        end
      end

      attr_accessor :simplecov_threshold
      attr_accessor :rspec_files_structure_ignored
      attr_accessor :expires_in_files_ignored
      attr_accessor :final_blank_line_in_files_ignored

      # Available commands
      # All commands will be executed in this order (first rubocop, then rspec, etc)
      COMMANDS = %i(
        final_blank_line
        readme
        expires_in
        brakeman
        rubocop
        haml_lint
        allowed_extensions
        yml_parser
        rspec_files_names
        rspec_files_structure
        tasks_files_names
        rspec
        simplecov
        coverage
        yard
        examples_comparator
        rubycritic
      )

      COMMANDS.each do |attr_name|
        attr_accessor attr_name

        # @return [Boolean] is given command enabled
        define_method :"#{attr_name}?" do
          public_send(attr_name) == true
        end
      end

      # Initializes configuration and turn on by default
      # all the commands
      def initialize
        COMMANDS.each do |attr_name|
          public_send(:"#{attr_name}=", true)
        end

        self.simplecov_threshold = 100
      end

      # Configurating method
      def self.setup(&block)
        self.config = new

        config.detect_framework

        block.call(config)
        config.freeze
      end

      # Detects if we use Rails, Sinatra or nothing
      # We need to set it because some of the commands might work only for Rails
      # or Sinatra (like brakeman for example - only Rails)
      def detect_framework
        define_singleton_method :rails? do
          !defined?(Rails).nil?
        end

        define_singleton_method :sinatra? do
          !defined?(App).nil?
        end
      end
    end
  end
end
