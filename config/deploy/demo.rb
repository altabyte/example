set :rails_env, 'demo'

namespace :deploy do
  task :final_tasks do
    run "cd #{current_path}; bundle exec rake order_manager:cleandb RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake order_manager:import_hs_codes RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake order_manager:post_deploy_tasks RAILS_ENV=#{rails_env}"
  end
end