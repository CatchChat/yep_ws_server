namespace :bluepill do

  desc 'Bluepill load'
  task :load do
    worker_processes = fetch(:goliath_worker_processes).to_i
    worker_processes = 1 if worker_processes <= 0
    start_port       = fetch(:goliath_start_port).to_i || 9000
    start_port       = 9000 if start_port <= 0
    pidfile_path     = fetch(:goliath_pidfile_path) || 'tmp/pids'
    goliath_env      = fetch(:goliath_env) || fetch(:stage)
    on roles(:app) do
      within current_path do
        execute :sudo, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} WORKING_DIR=#{current_path} WORKER_PROCESSES=#{worker_processes} START_PORT=#{start_port} GOLIATH_ENV=#{goliath_env} PIDFILE_PATH=#{pidfile_path} bluepill load yep_ws_server.pill"
      end
    end
  end

  desc 'Bluepill start'
  task :start do
    on roles(:app) do
      execute :sudo, "bluepill yep_ws_server start"
    end
  end

  desc 'Bluepill restart'
  task :restart do
    on roles(:app) do
      execute :sudo, "bluepill yep_ws_server restart"
    end
  end

  desc 'Bluepill stop'
  task :stop do
    on roles(:app) do
      execute :sudo, "bluepill yep_ws_server stop"
    end
  end

  desc 'Bluepill quit'
  task :quit do
    on roles(:app) do
      execute :sudo, "bluepill yep_ws_server quit"
    end
  end

  desc 'Bluepill status'
  task :status do
    on roles(:app) do
      execute :sudo, "bluepill yep_ws_server status"
    end
  end
end
