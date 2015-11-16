%w(
  yaml
  yard
  pry
  fileutils
  timecop
  faker
  ostruct
).each { |lib| require lib }

%w(
  validators/base
  commands/base
  commands/empty_methods
  commands/empty_methods/string_refinements
).each { |lib| require "polishgeeks/dev-tools/#{lib}" }

%w(
  *.rb
  validators/*.rb
  commands/*.rb
  commands/**/*.rb
).each do |path|
  base_path = File.dirname(__FILE__) + "/polishgeeks/dev-tools/#{path}"
  Dir[base_path].each { |file| require file }
end

module PolishGeeks
  module DevTools
    # This is just an alias so we can use it from DevTools directly
    # @return [PolishGeeks::DevTools::Config.config]
    def self.config
      Config.config
    end

    # @return [String] root path of this gem
    def self.gem_root
      File.expand_path('../..', __FILE__)
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

load 'polishgeeks/dev-tools/tasks/dev-tools.rake'
