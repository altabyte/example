class Report < ActiveRecord::Base
  mount_uploader :report_file, ReportUploader
  belongs_to :user
  belongs_to :company

  ORDER_PICK_NOTE = "ORDER_PICK_NOTE"
  ORDER_SHIPMENT_NOTE = "ORDER_SHIPMENT_NOTE"


  scope :by_company, lambda { |company_id|
                     where(['reports.company_id IN (?)', company_id]) if company_id.present?
                   }

  def self.add_report(report_type, report_file_name, current_user, delete=true)
    begin
      actual_report_file = File.open(report_file_name)

      report = Report.new
      #report.application_id = associated_object.id
      report.date_time = Time.now
      report.report_file = actual_report_file
      report.report_type = report_type
      report.opened_flag = "N"
      report.user_id = current_user.id
      report.company_id = current_user.company_id rescue nil

      report.save
      File.delete(report_file_name) if delete

      report
    rescue => e
      Rails.logger.info "Error generating report for #{report_type}"
      Rails.logger.info e.inspect
    end
  end

  def self.dashboard_data
    now = Time.now
    if User.current_user.check_role?("User")
      {
          :life_time_orders => (Order.all.count rescue 0),
          :new_orders => (Order.find_all_by_status(Order::STATUS_NEW).count rescue 0),
          :customers => (Customer.all.count rescue 0),
          :pending_orders => (Order.find_all_by_status(Order::STATUS_PENDING).count rescue 0)
      }
    else
      {
          :life_time_orders => (Order.where(:original_order_id => nil).all.count rescue 0),
          :new_orders => (Order.where(:original_order_id => nil).find_all_by_status(Order::STATUS_NEW).count rescue 0),
          :customers => (Customer.all.count rescue 0),
          :pending_orders => (Order.where(:original_order_id => nil).where(:status => Order::STATUS_PENDING).count rescue 0),
          :todays_order_count => Order.where(:original_order_id => nil).where("order_date > '#{now.beginning_of_day.to_s(:db)}'").count,
          :weeks_order_count => Order.where(:original_order_id => nil).where("order_date > '#{now.beginning_of_week.to_s(:db)}'").count,
          :months_order_count => Order.where(:original_order_id => nil).where("order_date > '#{now.beginning_of_month.to_s(:db)}'").count,
          :todays_order_value => (Order.where(:original_order_id => nil).where("order_date > '#{now.beginning_of_day.to_s(:db)}'").sum('order_total') rescue 0),
          :weeks_order_value => (Order.where(:original_order_id => nil).where("order_date > '#{now.beginning_of_week.to_s(:db)}'").sum('order_total') rescue 0),
          :months_order_value => (Order.where(:original_order_id => nil).where("order_date > '#{now.beginning_of_month.to_s(:db)}'").sum('order_total') rescue 0)
      }
    end

  end


end
