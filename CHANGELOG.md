# PolishGeeks Dev Tools Changelog

## 1.3.0
- Bump rubocop dependency to 0.35.1
- #17: Bump rubycritic dependency to 2.1.0
- Bump rspec dependency to 3.4.0
- Bump activemodel dependency to 4.2.5
- #18: Add bundler-audit which checks for vulnerable versions of gems
- #21: Replace readme validator with required files validators, which allows us to
  define what files you want to require in your project

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
