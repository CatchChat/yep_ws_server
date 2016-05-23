namespace :deploy do

  desc 'Upload linked files'
  task :upload_linked_files do
    stage = fetch(:stage)
    on roles(:app) do
      execute :mkdir, "-p #{shared_path}"

      within shared_path do
        fetch(:linked_dirs, []).each do |dir|
          execute :mkdir, "-p #{dir}"
        end

        fetch(:linked_files, []).each do |file|
          if (dirname = File.dirname(file)) != '.'
            execute :mkdir, "-p #{dirname}"
          end

          if File.exist?("#{file}.#{stage}")
            upload! "#{file}.#{stage}", "#{shared_path}/#{file}"
          else
            upload! file, "#{shared_path}/#{file}"
          end
        end
      end
    end
  end
end
