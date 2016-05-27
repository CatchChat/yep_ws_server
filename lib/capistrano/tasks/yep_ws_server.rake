namespace :yep_ws_server do
  desc 'Start yep_ws_server server'
  task :start do
    on roles(:app) do
      worker_processes = fetch(:goliath_worker_processes).to_i
      worker_processes = 1 if worker_processes <= 0
      start_port       = fetch(:goliath_start_port).to_i || 9000
      start_port       = 9000 if start_port <= 0
      pidfile_path     = fetch(:goliath_pidfile_path) || 'tmp/pids'
      goliath_env      = fetch(:goliath_env) || fetch(:stage)
      _running_port_with_pid_map = get_running_port_with_pid_map(goliath_env)
      within current_path do
        if _running_port_with_pid_map.keys.size == worker_processes
          info 'Server is running.'
        else
          all_ports  = (start_port...(start_port + worker_processes)).to_a
          dead_ports = all_ports - _running_port_with_pid_map.keys

          info "Need start ports: #{dead_ports}"
          dead_ports.each do |port|
            execute :ruby, "yep_ws_server.rb -e #{goliath_env} -p #{port} -d -l log/#{goliath_env}.log -P #{pidfile_path}/#{port}.pid"
          end
        end
      end
    end
  end

  desc 'Stop yep_ws_server server'
  task :stop do
    on roles(:app) do
      pidfile_path = fetch(:goliath_pidfile_path) || 'tmp/pids'
      goliath_env  = fetch(:goliath_env) || fetch(:stage)
      within current_path do
        execute :kill, "-TERM `ps aux | grep '[r]uby yep_ws_server.rb -e #{goliath_env}' | grep -v grep | cut -c 10-16` > /dev/null 2>&1 || true"
        3.times { print '.'; sleep 1 }
        puts "\n"
        execute :kill, "-9 `ps aux | grep '[r]uby yep_ws_server.rb -e #{goliath_env}' | grep -v grep | cut -c 10-16` > /dev/null 2>&1 || true"
        execute :rm, "#{pidfile_path}/*.pid > /dev/null 2>&1 || true"
      end
    end
  end

  desc 'Restart yep_ws_server server'
  task :restart do
    on roles(:app) do
      worker_processes = fetch(:goliath_worker_processes).to_i
      worker_processes = 1 if worker_processes <= 0
      start_port       = fetch(:goliath_start_port).to_i || 9000
      start_port       = 9000 if start_port <= 0
      pidfile_path     = fetch(:goliath_pidfile_path) || 'tmp/pids'
      goliath_env      = fetch(:goliath_env) || fetch(:stage)
      _running_port_with_pid_map = get_running_port_with_pid_map(goliath_env)
      all_ports     = (start_port...(start_port + worker_processes)).to_a
      running_ports = _running_port_with_pid_map.keys
      dead_ports    = all_ports - _running_port_with_pid_map.keys
      within current_path do
        info "Need restart ports: #{running_ports}"
        running_ports.each do |port|
          execute :kill, "-HUP #{_running_port_with_pid_map[port]}"
        end

        info "Need start ports: #{dead_ports}"
        dead_ports.each do |port|
          execute :ruby, "yep_ws_server.rb -e #{goliath_env} -p #{port} -d -l log/#{goliath_env}.log -P #{pidfile_path}/#{port}.pid"
        end
      end
    end
  end

  # deploy   11603  0.0  1.9 283020 40112 ?        Sl   17:39   0:00 ruby yep_ws_server.rb -e staging -p 9000 -d -l log/staging.log -P tmp/pids/9000.pid
  def get_running_port_with_pid_map(goliath_env)
    ps_result = capture("ps aux | grep '[r]uby yep_ws_server.rb -e #{goliath_env}' | grep -v grep") rescue ''
    ps_result.split("\n").inject({}) do |port_with_pid_map, str|
      array = str.split(' ')
      port_with_pid_map[array[15].to_i] = array[1].to_i
      port_with_pid_map
    end
  end
end
