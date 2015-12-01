module PolishGeeks
  module DevTools
    module Commands
      # A static analysis security vulnerability scanner for Ruby on Rails applications
      # @see https://github.com/presidentbeef/brakeman
      class Brakeman < Base
        self.config_name = '.brakeman.yml'
        self.type = :validator
        self.validators = [
          Validators::Rails
        ]

        # Regexps to get some stat info from brakeman output
        REGEXPS = {
          controllers: /Controller.* (\d+)/,
          models: /Model.* (\d+)/,
          templates: /Template.* (\d+)/,
          errors: /Error.* (\d+)/,
          warnings: /Warning.* (\d+)/
        }

        # Executes this command
        # @return [String] command output
        def execute
          cmd = ['bundle exec brakeman -q']
          cmd << "-c #{config}" if config?
          @output = Shell.new.execute(cmd.join(' '))
        end

        # @return [Boolean] true if we didn't have any vulnerabilities detected
        def valid?
          warnings == 0 && errors == 0
        end

        # @return [String] label with details bout brakeman scan
        def label
          "Brakeman (#{controllers} con, #{models} mod, #{templates} temp)"
        end

        REGEXPS.each do |name, regexp|
          # @return [Integer] number of matches for given regexp
          define_method(name) do
            output.scan(regexp).flatten.first.to_i
          end

          private name
        end
      end
    end
  end
end
