require 'bundler'
require 'rake'
require 'polishgeeks-dev-tools'

desc 'Self check using command maintained in this gem'
task :check do
  PolishGeeks::DevTools.setup do |config|
    config.brakeman = false
    config.haml_lint = false
    config.expires_in_files_ignored = %w(
      lib/polishgeeks/dev-tools/commands/expires_in.rb
    )
    config.empty_method_ignored = %w(
      empty_method_spec.rb
      file_parser_spec.rb
    )
  end

  PolishGeeks::DevTools::Runner.new.execute(
    PolishGeeks::DevTools::Logger.new
  )
end

task default: :check
