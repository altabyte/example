class OrderStatusHistory < ActiveRecord::Base
  belongs_to :order

  def self.new_status_update(order_id, old_status, new_status)
    user_id = User.current_user.id unless User.current_user.nil?
    user_id ||= nil
    OrderStatusHistory.create(
        :order_id => order_id,
        :old_status => old_status,
        :new_status => new_status,
        :user_id => user_id
    )
  end

end
