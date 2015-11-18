require 'rake'

namespace :polishgeeks do
  namespace :'dev-tools' do
    desc 'Executed all tests and checks for given project'
    task :check do
      # Load Rails framework if it's Rails app
      Rake::Task[:environment].invoke if Rake::Task.task_defined?(:environment)

      PolishGeeks::DevTools::Runner.new.execute(
        PolishGeeks::DevTools::Logger.new
      )
    end
  end
end
