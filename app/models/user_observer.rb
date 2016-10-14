class UserObserver < ActiveRecord::Observer
  observe :user

  def after_create(record)

    if User.current_user.present?
      record.creating_user_id = User.current_user.id
      record.save

      Mailer.welcome_email(record).deliver

      #assign user to all stock locations
      if record.company_id.present?
        company_stock_locations = StockLocation.find_all_by_company_id(record.company_id)
        company_stock_locations.each do |user_stock_location|
          slu = StockLocationUser.new
          slu.stock_location_id = user_stock_location.id
          slu.user_id = record.id
          slu.save
        end
      end
    end

  end
end
