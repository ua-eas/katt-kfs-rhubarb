# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/console'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails/tree/master/assets
#   https://github.com/capistrano/rails/tree/master/migrations
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/bundler'
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

namespace :deploy do

  desc 'Bundle'
  task :bundler do
    on roles :all do
      within release_path do
        #execute "source $HOME/.bash_profile && cd #{release_path} && bundle install --without test deploy"
        execute "source $HOME/.bash_profile && cd #{release_path} && bundle install --without test deploy"
         
      end
    end
  end

  after :updated, 'deploy:bundler'

  after :finishing, 'deploy:cleanup'

end