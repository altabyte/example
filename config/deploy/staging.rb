set :rails_env, 'staging'

before 'deploy', 'deploy:load_live_db'

namespace :deploy do
  task :load_live_db do
    run "cd #{current_path}; mysqladmin -udeploy -pd-JwkL6P?+l4 drop ordermanager_staging -f"
    run "cd #{current_path}; mysqladmin -udeploy -pd-JwkL6P?+l4 create ordermanager_staging"
    run "cd #{current_path}; mysqldump -u deploy -pd-JwkL6P?+l4 ordermanager_production > oms_production.sql"
    run "cd #{current_path}; mysql -u deploy -pd-JwkL6P?+l4 ordermanager_staging < oms_production.sql"
    run "cd #{current_path}; rm oms_production.sql"
  end

  task :final_tasks do
    run "cd #{current_path}; bundle exec rake order_manager:import_hs_codes RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; bundle exec rake order_manager:post_deploy_tasks RAILS_ENV=#{rails_env}"
  end
end

