module PolishGeeks
  # Allows us to get config, gem_root, app_root and setup
  module DevTools
    # This is just an alias so we can use it from DevTools directly
    # @return [PolishGeeks::DevTools::Config.config]
    def self.config
      Config.config
    end

    # @return [String] root path of this gem
    def self.gem_root
      File.expand_path('../../..', __FILE__)
    end

    # @return [String] app root path
    def self.app_root
      File.dirname(ENV['BUNDLE_GEMFILE'])
    end

    # Sets up the whole configuration
    # @param [Block] block
    def self.setup(&block)
      Config.setup(&block)
    end
  end
end
