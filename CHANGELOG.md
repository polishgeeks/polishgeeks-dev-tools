# PolishGeeks Dev Tools Changelog

## 1.2.2
- Bump rubocop dependency to 0.35.1

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
