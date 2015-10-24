require 'yaml'
require 'yard'
require 'pry'
require 'fileutils'
require 'timecop'
require 'faker'
require 'ostruct'

base_path = File.dirname(__FILE__) + '/polishgeeks/dev-tools/*.rb'
Dir[base_path].each { |file| require file }

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

validators_path = File.dirname(__FILE__) + '/polishgeeks/dev-tools/validators/*.rb'
Dir[validators_path].each { |file| require file }

require 'polishgeeks/dev-tools/commands/base'
require 'polishgeeks/dev-tools/commands/empty_method'
require 'polishgeeks/dev-tools/commands/empty_method/string_refinements'

commands_path = File.dirname(__FILE__) + '/polishgeeks/dev-tools/commands/*.rb'
Dir[commands_path].each { |file| require file }

commands_path = File.dirname(__FILE__) + '/polishgeeks/dev-tools/commands/**/*.rb'
Dir[commands_path].each { |file| require file }

load 'polishgeeks/dev-tools/tasks/dev-tools.rake'
