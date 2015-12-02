module PolishGeeks
  module DevTools
    # Config manager which is able to check if config file exist either in local
    # or application path
    # @example
    #   config_manager = ConfigManager.new('rubocop.yml')
    #   config_manager.present? = true
    #   config_manager.path = /home/pg/project/.rubocop.yml
    class ConfigManager
      def initialize(file_name)
        @file_name = file_name
      end

      # @return [Boolean] true if there is a local or application config file present
      def present?
        application? || local?
      end

      # If there is an application config file use that, if not
      # check if local config file is available if not return nil
      # @return [String] path to config file or nil
      # @example
      #   /home/pg/project/.rubocop.yml
      def path
        application? ? application_path : local_path
      end

      private

      # @return [Boolean] true if there is a config present locally
      def local?
        !@file_name.nil? && !local_path.nil?
      end

      # Provides path to local config file if it exists
      # @return [String] path to local config file
      def local_path
        fetch_path(DevTools.gem_root)
      end

      # @return [Boolean] true if there is a config present in the application
      def application?
        !@file_name.nil? && !application_path.nil?
      end

      # Provides path to application config file if it exists
      # @return [String] path to application config file
      def application_path
        fetch_path(DevTools.app_root)
      end

      # Searches for provided file name as well as one with dot in front of it
      # in main directory and config subdirectory
      # @return [String] path to config file if it exists
      # @example
      #   /home/pg/project/.rubocop.yml
      def fetch_path(start_path)
        ['', 'config'].each do |directory|
          ['', '.'].each do |prefix|
            path = File.join(start_path, directory, "#{prefix}#{@file_name}")
            return path if File.exist?(path)
          end
        end
        nil
      end
    end
  end
end
