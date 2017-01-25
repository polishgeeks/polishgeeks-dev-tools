$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'polish_geeks/dev_tools/version'

Gem::Specification.new do |s|
  s.name        = 'polishgeeks-dev-tools'
  s.version     = PolishGeeks::DevTools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Maciej Mensfeld']
  s.email       = ['maciej@mensfeld.pl']
  s.homepage    = ''
  s.summary     = 'Set of tools used when developing Ruby based apps'
  s.description = 'Set of tools used when developing Ruby based apps'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'

  s.add_dependency 'bundler-audit'
  s.add_dependency 'simplecov'
  s.add_dependency 'rubycritic'
  s.add_dependency 'yard'
  s.add_dependency 'rspec'
  s.add_dependency 'rubocop'
  s.add_dependency 'rubocop-rspec'
  s.add_dependency 'timecop'
  s.add_dependency 'brakeman'
  s.add_dependency 'haml_lint'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = %w( lib )
end
