#after "deploy:stop", "clockwork:stop"
#after "deploy:start", "clockwork:start"
#after "deploy:restart", "clockwork:restart"
#
#namespace :clockwork do
#  desc "Stop clockwork"
#  task :stop, :roles => clockwork_roles, :on_error => :continue, :on_no_matching_servers => :continue do
#    run "if [ -d #{current_path} ] && [ -f #{pid_file} ]; then cd #{current_path} && kill -INT `cat #{pid_file}` ; fi"
#  end
#
#  desc "Start clockwork"
#  task :start, :roles => clockwork_roles, :on_no_matching_servers => :continue do
#    run "daemon --inherit --name=clockwork --env='#{rails_env}' --output=#{log_file} --pidfile=#{pid_file} -D #{current_path} -- bundle exec clockwork lob/clock.rb"
#  end
#
#  desc "Restart clockwork"
#  task :restart, :roles => clockwork_roles, :on_no_matching_servers => :continue do
#    stop
#    start
#  end
#
#  def rails_env
#    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
#  end
#
#  def log_file
#    fetch(:clockwork_log_file, "#{current_path}/log/clockwork.log")
#  end
#
#  def pid_file
#    fetch(:clockwork_pid_file, "#{current_path}/tmp/pids/clockwork.pid")
#  end
#end