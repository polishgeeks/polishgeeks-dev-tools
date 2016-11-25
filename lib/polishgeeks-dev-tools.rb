# Require all from files array. If prefix is set method paste it before every file
# @param [Array<String>] files to require
# @param [String] prefix path
def require_files(files, prefix = nil)
  files.each do |file|
    require prefix ? File.join(prefix, file) : file
  end
end

# Require all file from dirs array. If prefix is set method paste it before every dir
# @param [Array<String>] dirs from whic we want require files
# @param [String] prefix path
def require_dirs(dirs, prefix = 'polish_geeks/dev_tools')
  dirs.each do |path|
    base_path = File.join(File.dirname(__FILE__), prefix, path)
    Dir[base_path].each { |file| require file }
  end
end

require_files(
  %w(
    yaml
    yard
    pry
    fileutils
    timecop
    faker
    ostruct
  )
)

require_dirs(
  %w(
    helpers/**/*.rb
  )
)

require_files(
  %w(
    validators/base
    commands/base
    commands/empty_methods
    commands/empty_methods/string_refinements
  ),
  'polish_geeks/dev_tools'
)

require_dirs(
  %w(
    *.rb
    validators/*.rb
    commands/*.rb
    commands/**/*.rb
  )
)

require 'polish_geeks/dev_tools'
load 'polish_geeks/dev_tools/tasks/dev-tools.rake'
