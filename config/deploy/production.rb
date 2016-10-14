set :rails_env, 'production'
require "clockwork"

namespace :god do
  desc "Stop god"
  task :stop do
    run "sudo /etc/init.d/god stop"
  end

  desc "Start god"
  task :start do
    run "sudo /etc/init.d/god start"
  end
end

before "deploy:update", "god:stop"
after "deploy", "god:start"


namespace :deploy do
  task :final_tasks do
    run "cd #{current_path}; bundle exec rake order_manager:update_system_settings RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake order_manager:import_hs_codes RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake order_manager:post_deploy_tasks RAILS_ENV=#{rails_env}"
  end
end

