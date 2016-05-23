# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'yep_ws_server'
set :repo_url, 'git@github.com:CatchChat/yep_ws_server.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/u/apps/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, ['.env', '.ruby-version', 'yep_ws_server.pill'])

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rbenv_ruby, '2.2.2'
set :rbenv_custom_path, '/opt/rbenv'

# Server
set :goliath_worker_processes, 1
set :goliath_start_port, 10000
set :goliath_pidfile_path, 'tmp/pids'
set :goliath_env, fetch(:stage)

namespace :deploy do
  task :start do
    invoke 'yep_ws_server:start'
    invoke 'bluepill:load'
  end

  task :restart do
    invoke 'yep_ws_server:restart'
  end

  task :stop do
    invoke 'bluepill:quit'
    invoke 'yep_ws_server:stop'
  end

  after 'deploy:published', 'yep_ws_server:restart', 'bluepill:load'
end
