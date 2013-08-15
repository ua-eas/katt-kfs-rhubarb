set :application, 'Rhubarb'
set :repo_url, 'https://github.com/ua-eas/katt-kfs-rhubarb.git'

#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/opt/kuali/rhubarb/rhubarb-1.0"
set :scm, :git

set :format, :pretty
set :log_level, :debug
set :pty, true

# Ensure we source the .bash_profile to setup kualiadm's environment
#set :bundle, 'source $HOME/.bash_profile && bundle'

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_environment, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5
