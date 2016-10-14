namespace :tracking do
  desc "Get tracking information form aftership"
  task :download => :environment do
    Order.update_aftership_statuses
  end
end
