# PolishGeeks Dev Tools

[![Build Status](https://travis-ci.org/polishgeeks/polishgeeks-dev-tools.png)](https://travis-ci.org/polishgeeks/polishgeeks-dev-tools)
[![Code Climate](https://codeclimate.com/github/polishgeeks/polishgeeks-dev-tools/badges/gpa.svg)](https://codeclimate.com/github/polishgeeks/polishgeeks-dev-tools)

Gem with a set of useful tools used when developing Ruby based applications.

## Installation

```ruby
group :development, :test do
  gem 'polishgeeks-dev-tools'
end
```

## Setup

There are multiple options you can set either to true or false. All of them are available with configurator. Please use it only for development and testing environments. This config should be put in config/initializers/polishgeeks_dev_tools.rb file.

Note that all the options are turned on by default it depends on an app, which of the you should use.

If you want to use DevTools with all the default settings, you don't need to create an initializer.

### Rack apps (Sinatra)
```ruby
if %i( test development ).include?(App.environment)
  PolishGeeks::DevTools.setup do |config|
    # For example - lowering a simplecov_threshold
    config.simplecov_threshold = 98
  end
end
```
### Rack apps (Rails)
```ruby
if %w( test development ).include?(Rails.env)
  PolishGeeks::DevTools.setup do |config|
    config.brakeman = true # Rails only
    # You can disable any command that is executed by setting it to false
    config.rubycritic = false
  end
end
```

### Available options

Some options might be available only for given framework (Ruby on Rails, Sinatra, etc). Please refer to this table to
determine, which you can use in your project:

| Option                | Framework | Description                                                                           |
|-----------------------|-----------|---------------------------------------------------------------------------------------|
| brakeman              | Rails     | A static analysis security vulnerability scanner for Ruby on Rails                    |
| rubocop               | -         | Used to check Ruby syntax according to our styling                                    |
| final_blank_line      | -         | Check if all files have final blank line                                              |
| expires_in            | -         | Checks if there are typos like expire_in, etc that might brake app caching            |
| haml_lint             | -         | User to check HAML syntax in the app views                                            |
| yard                  | -         | YARD documentation standards checking                                                 |
| rspec_files_names     | -         | Checks if all the rspec files have proper sufix (_spec.rb)                            |
| rspec_files_structure | -         | Checks if we have corresponding _spec.rb files for each app/ lib ruby file            |
| tasks_files_names     | -         | Checks if all the tasks for Capistrano and Rake files have proper extensions          |
| rspec                 | -         | Specs framework                                                                       |
| coverage              | -         | Specs code coverage generator                                                         |
| simplecov             | -         | Simplecov code coverage threshold checking                                            |
| simplecov_threshold   | -         | Threshold level for code coverage                                                     |
| examples_comparator   | -         | Compares yml *.example files with non-examples and checks if they have same structure |
| rubycritic            | -         | Generates a RubyCritic for given project                                              |
| allowed_extensions    | -         | Checks that all the files in ./config directory have an allowed extension             |
| yml_parser            | -         | Checks that parameters of all yaml files in ./config directory have some value        |

## Config options

Some validators might accept additional config settings - please refer to this table for a description on how to use them:

| Option                        | Validator             | Description                                              |
|-------------------------------|-----------------------|----------------------------------------------------------|
| rspec_files_structure_ignored | rspec_files_structure | You can provide an array of files that should be ignored |
| final_blank_line_ignored      | final_blank_line      | You can provide an array of files (ex. lib/file.rb) or   |
|                               |                       | path (ex. lib/**/*) should be ignored.                   |
|                               |                       | If you want ignore hidden file (ex .gitignore),          |
|                               |                       | you should use {*,.*} expression (ex lib/**/{*,.*})      |

## Usage in any Rails/Ruby application

Once you've set up all the options and a config initializer, please execute following command:

```bash
bundle exec rake polishgeeks:dev-tools:check
```

## Usage with other Ruby gems

If you want to use this gem to check other gems quality, you will have to put following things in your gem Rakefile:

```ruby
require 'bundler'
require 'rake'
require 'polishgeeks-dev-tools'

desc 'Self check using command maintained in this gem'
task :check do
  PolishGeeks::DevTools.setup do |config|
    # Any config option you want to disable/enable
    config.brakeman = false
  end

  PolishGeeks::DevTools::Runner.new.execute(
    PolishGeeks::DevTools::Logger.new
  )
end

task default: :check
```

And then from command line, run:

```bash
bundle exec rake
```
