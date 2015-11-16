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
).each { |lib| require "polish_geeks/dev_tools/#{lib}" }

%w(
  *.rb
  validators/*.rb
  commands/*.rb
  commands/**/*.rb
).each do |path|
  base_path = File.dirname(__FILE__) + "/polish_geeks/dev_tools/#{path}"
  Dir[base_path].each { |file| require file }
end

require 'polish_geeks/dev_tools'
load 'polish_geeks/dev_tools/tasks/dev-tools.rake'
