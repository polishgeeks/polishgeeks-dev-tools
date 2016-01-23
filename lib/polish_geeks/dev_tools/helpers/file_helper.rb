module PolishGeeks
  module DevTools
    # Helpers wrapper
    module Helpers
      # Helper useful to manage paths and files
      module FileHelper
        # @param [String] file name that we want to sanitize
        # @return [String] sanitized file name
        # @example
        #   file = /home/something/app/lib/lib.rb,
        #   where /home/something/app/ is a app root path, then
        #   sanitize(file) #=> lib/lib.rb
        def sanitize(file)
          file.gsub("#{PolishGeeks::DevTools.app_root}/", '')
        end

        # @param [String] path from which we want take files
        # @return [Array<String>] list of files in path with app prefix path
        # @note if path is a file return array with file path with app prefix path
        def files_from_path(path)
          full_path = "#{::PolishGeeks::DevTools.app_root}/#{path}"
          return [full_path] if File.file?(full_path)

          Dir.glob(full_path).select { |f| File.file? f }
        end
      end
    end
  end
end
