# PolishGeeks Dev Tools Changelog

## master (unreleased)
- bump to ruby 2.3.3
- drop support for ruby 2.1.x
- haml_lint 0.18.4

## 1.3.2 (27/06/2016)

- Bump rubycritic dependency to 2.9.1
- Bump brakeman dependency to 3.3.2
- Bump rubocop-rspec dependency to 1.5.0

## 1.3.1 (15/04/2016)

- Remove dependency for mongoid-rspec
- #54: Fix Command::Rspec to handle single test failure
- Bump rubycritic dependency to 2.9.0
- #58: Rename haml-lint gem to haml_lint

## 1.3.0 (03/04/2016)

- Move to ruby 2.3.0 by default
- Bump bundler-audit dependency to 0.5.0
- Bump brakeman dependency to 3.2.1
- Bump simplecov dependency to 0.11.2
- Bump rspec dependency to 3.4.4
- Reorganize how we run rubocop-rspec
- #44: Bump rubocop dependency to 0.39.0
- #17: Bump rubycritic dependency to 2.8.0
- #30: Allow to pass config file to brakeman
- #18: Add bundler-audit which checks for vulnerable versions of gems
- #21: Replace readme validator with required files validators, which allows us to
  define what files you want to require in your project
- #35: Added gemfile validator which checks if Gemfile contains gems from local path

If you had readme validator turned off like this
```ruby
  PolishGeeks::DevTools.setup do |config|
    config.readme = false
  end
```
Now you need to change that to
```ruby
  PolishGeeks::DevTools.setup do |config|
    config.required_files = false
  end
```
You can now add extra files for validation
```ruby
  PolishGeeks::DevTools.setup do |config|
    config.required_files_include = %w(REVIEW.md)
  end
```

- #26: Rename empty_method to empty_methods validator

If you had empty_method validator turned off like this and had files ignored
```ruby
  PolishGeeks::DevTools.setup do |config|
    config.empty_method = false
    config.empty_method_ignored = %w(REVIEW.md)
  end
```
Now you need to change that to
```ruby
  PolishGeeks::DevTools.setup do |config|
    config.empty_methods = false
    config.empty_methods_ignored = %w(REVIEW.md)
  end
```

- #12: Add rubocop-rspec which checks add code style checking for your RSpec files
- #33: Add an option to disallow pending specs

If you want to allow pending specs then
```ruby
  PolishGeeks::DevTools.setup do |config|
    config.rspec_disallow_pending = false
  end
```

## 1.2.1

- Extracted all errors to PolishGeeks::DevTools::Errors namespace
- Add support for validators
- Rename Command to Commands namespace

## 1.2.0

- Added EmptyMethod command which checks if some files have empty methods

## 1.1.2

- Ignore .DS_Store files in FinalBlankLine validator.
- Changed FinalBlankLine excluded mechanism. You can define directories and files (ex. lib/command or lib/file.rb). Please don't use path with stars convention (ex. lib/**/*).

## 1.1.1

- Ignore doc directory in FinalBlankLine validator

## 1.1.0

- Added FinalBlankLine command which check if all files have new line at the end
