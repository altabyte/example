require "rvm/capistrano"
require 'bundler/capistrano'
require './config/boot'
# require 'rollbar/capistrano'
# set :rollbar_token, '75cab18183da4ce4bc63dad884d570af'


set :stages, %w(production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

load 'deploy/assets'

ssh_options[:port] = 23121

set :bundle_flags, "--deployment --binstubs"
set :user, 'deploy'
set :domain, '23.254.97.185'
set :application, "ordermanager"
set :server_name, "23.254.97.185"

set :scm, :git
set :branch, "master"
set :repository, 'git@bitbucket:stuartdrennan/oms.git'
set :deploy_via, :remote_cache
#ssh_options[:forward_agent] = true
set :keep_releases, 2
set :bundle_without, [:development, :test]

# roles (servers)
role :web, domain
role :app, domain
role :db, domain, :primary => true
set(:deploy_to) { "/var/www/#{rails_env}/#{application}" }

set :use_sudo, false
set :group_writable, false

# set the proper permission of the public folder
task :after_update_code, :roles => [:web, :db, :app] do
  run "chmod 755 #{current_path}/public"
end

# Passenger
namespace :deploy do
  task :start do
  end
  task :stop do
  end
  task :restart do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
  #desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
  task :cleandb do
    run "cd #{current_path}; bundle exec rake order_manager:cleandb RAILS_ENV=#{rails_env}"
  end
end

#standard deployment tasks
after "deploy", "deploy:migrations"
after "deploy:update", "deploy:cleanup"
after "deploy", "deploy:final_tasks"
after "deploy:create_symlink", "customs:symlink"

before "deploy:restart", :update_version
# after "deploy:create_symlink", :update_database_yml


desc "Update database.yml with production information"
task :update_database_yml do
  replacements = {"ordermanager_production" => "#{rails_env}_production"}

  replacements.each_pair do |pattern, sub|
    run "sed -i 's/#{pattern}/#{sub}/' #{current_path}/config/database.yml"
  end
end

task :update_version do
  puts 'Updating Version'
  replacements = {'#{DateTime.now().strftime("%m%d%y")}' => "#{DateTime.now().strftime("%m%d%y")}"}

  replacements.each_pair do |pattern, sub|
    run "sed -i 's/#{pattern}/#{sub}/' #{current_path}/lib/version.rb"
  end
end


# set the proper permission of the public folder
task :after_update_code, :roles => [:web, :db, :app] do
  run "chmod 755 #{current_path}/public"
end

namespace :customs do
  task :symlink, :roles => :app do
    run "ln -nfs /home/deploy/client_shares/ #{current_path}/export"
    run "ln -nfs /var/www/production/ordermanager/shared/uploads/ #{current_path}/public/uploads"
  end
end


#db tasks setup
require 'capistrano-db-tasks'

# if you want to remove the dump file after loading
set :db_local_clean, true

