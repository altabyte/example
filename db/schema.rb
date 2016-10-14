# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150315170431) do

  create_table "addresses", :force => true do |t|
    t.string   "name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "town"
    t.string   "county"
    t.string   "post_code"
    t.string   "country"
    t.string   "telephone"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "amazon_reports", :force => true do |t|
    t.integer  "company_id"
    t.string   "document_id"
    t.datetime "submission_datetime"
    t.text     "payload"
    t.datetime "payload_datetime"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "channel_id"
    t.integer  "messages_processed"
    t.integer  "messages_successful"
    t.integer  "messages_with_error"
    t.integer  "messages_with_warning"
  end

  create_table "channel_shipping_services", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "shipping_service_id"
    t.string   "shipping_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "useable_text"
    t.string   "highlight_colour"
    t.boolean  "next_day"
    t.string   "font_colour"
  end

  add_index "channel_shipping_services", ["channel_id", "shipping_service_id", "shipping_text"], :name => "channel_shipping_services_UK1", :unique => true

  create_table "channel_statuses", :force => true do |t|
    t.integer  "channel_id",         :null => false
    t.string   "status_name",        :null => false
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_outbound_status"
  end

  add_index "channel_statuses", ["channel_id", "status", "status_name"], :name => "channel_status_UK1", :unique => true

  create_table "channel_updates", :force => true do |t|
    t.integer  "channel_id"
    t.string   "info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "channel_updated_at"
  end

  add_index "channel_updates", ["channel_id", "info"], :name => "channel_updates_UK1", :unique => true

  create_table "channels", :force => true do |t|
    t.string   "system_channel_id",        :null => false
    t.text     "connection_1"
    t.string   "connection_2"
    t.string   "connection_3"
    t.string   "password_1_encrypted"
    t.string   "password_2_encrypted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "password_3_encrypted"
    t.integer  "company_id"
    t.string   "use_company_address_flag"
    t.integer  "return_address_id"
    t.string   "product_master"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "admin_user_id"
    t.boolean  "export_order"
    t.boolean  "inventory_feed"
    t.string   "terms_pdf"
    t.integer  "download_overlap"
    t.string   "connection_4"
  end

  add_index "channels", ["name", "company_id", "system_channel_id"], :name => "channels_UK1", :unique => true

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "town"
    t.string   "county"
    t.string   "post_code"
    t.string   "telephone"
    t.string   "fax"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "client_share"
    t.string   "terms_pdf"
    t.string   "aftership_api_key"
    t.integer  "user_id"
    t.string   "base_currency"
  end

  add_index "companies", ["name"], :name => "companies_UK1", :unique => true

  create_table "company_logs", :force => true do |t|
    t.integer  "company_id"
    t.datetime "date_timestamp"
    t.string   "log_level"
    t.text     "message"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "read",           :default => 0
  end

  create_table "company_packaging_types", :force => true do |t|
    t.integer  "company_id"
    t.integer  "packaging_type_id"
    t.decimal  "width",             :precision => 6, :scale => 2
    t.decimal  "length",            :precision => 6, :scale => 2
    t.decimal  "height",            :precision => 6, :scale => 2
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "name"
  end

  create_table "company_settings", :force => true do |t|
    t.integer  "system_setting_id"
    t.integer  "company_id"
    t.string   "value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "customer_addresses", :force => true do |t|
    t.integer  "customer_id"
    t.string   "address_type"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "town"
    t.string   "county"
    t.string   "country"
    t.string   "post_code"
    t.string   "telephone"
    t.string   "telephone_1"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "channel_address_id"
    t.string   "name"
    t.string   "company"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "customers", :force => true do |t|
    t.integer  "channel_id"
    t.string   "email",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "channel_customer_id"
    t.string   "phone_number"
    t.string   "mobile_number"
    t.string   "full_name"
    t.integer  "company_id"
  end

  add_index "customers", ["channel_id", "email"], :name => "customers_UK1", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "exchange_rates", :force => true do |t|
    t.string   "from_currency"
    t.string   "to_currency"
    t.integer  "company_id"
    t.decimal  "exchange_rate", :precision => 20, :scale => 10
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "fedex_settings", :force => true do |t|
    t.integer  "company_id"
    t.string   "key"
    t.string   "password"
    t.string   "account_number"
    t.string   "meter"
    t.string   "mode"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "label_type"
  end

  create_table "fedex_shipments", :force => true do |t|
    t.integer  "order_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "label_file_name"
    t.string   "label_content_type"
    t.integer  "label_file_size"
    t.datetime "label_updated_at"
    t.boolean  "printed_flag",       :default => false
  end

  create_table "hs_codes", :force => true do |t|
    t.string   "code"
    t.text     "description", :limit => 2147483647
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "item_inventories", :force => true do |t|
    t.integer  "item_id"
    t.integer  "stock_location_id"
    t.integer  "current_stock",     :default => 0
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "sku"
    t.string   "name"
    t.string   "description"
    t.string   "colour"
    t.string   "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "group_stock"
    t.string   "amazon_asin"
    t.string   "harmonization_code"
    t.string   "country_code"
    t.decimal  "item_weight",        :precision => 6, :scale => 2
  end

  add_index "items", ["sku"], :name => "items_UK1", :unique => true

  create_table "order_details", :force => true do |t|
    t.integer  "order_id"
    t.integer  "quantity_ordered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",              :precision => 8, :scale => 4
    t.decimal  "vat_amount",              :precision => 8, :scale => 4
    t.decimal  "line_total",              :precision => 8, :scale => 4
    t.string   "channel_order_detail_id"
    t.integer  "item_id"
    t.string   "gift_wrap_level"
    t.string   "gift_wrap_message"
    t.decimal  "gift_wrap_price",         :precision => 8, :scale => 4
  end

  add_index "order_details", ["order_id", "channel_order_detail_id"], :name => "order_details_UK1", :unique => true

  create_table "order_errors", :force => true do |t|
    t.integer  "order_id"
    t.string   "process"
    t.string   "error"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "order_fraud_scores", :force => true do |t|
    t.integer  "order_id"
    t.string   "last_four_digits"
    t.string   "avscv2"
    t.string   "address_result"
    t.string   "postcode_result"
    t.string   "cv2result"
    t.string   "threed_secure_status"
    t.string   "thirdman_action"
    t.integer  "thirdman_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_fraud_scores", ["order_id"], :name => "Order_Fraud_Score_UK1", :unique => true

  create_table "order_picks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "quantity_picked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "order_detail_id"
    t.integer  "order_id"
    t.integer  "item_id"
  end

  add_index "order_picks", ["order_id", "order_detail_id"], :name => "order_picks_IND2"
  add_index "order_picks", ["order_id"], :name => "order_picks_IND1"

  create_table "order_shipments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shipping_method_id"
    t.integer  "quantity_shipped"
    t.string   "tracking_details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock_location_id"
    t.integer  "item_id"
    t.integer  "order_detail_id"
    t.integer  "order_id"
  end

  add_index "order_shipments", ["order_id"], :name => "order_shipments_IND1"

  create_table "order_status_histories", :force => true do |t|
    t.integer  "order_id"
    t.string   "old_status"
    t.string   "new_status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "channel_id"
    t.string   "channel_order_id"
    t.integer  "customer_id"
    t.string   "status"
    t.datetime "order_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "shipping_cost",                :precision => 8, :scale => 4
    t.decimal  "subtotal",                     :precision => 8, :scale => 4
    t.decimal  "vat_amount",                   :precision => 8, :scale => 4
    t.decimal  "order_total",                  :precision => 8, :scale => 4
    t.integer  "channel_shipping_service_id"
    t.integer  "shipping_address_id"
    t.integer  "billing_address_id"
    t.integer  "override_shipping_service_id"
    t.string   "tracking_details"
    t.text     "order_xml"
    t.string   "shipment_error"
    t.string   "channel_shipping_id"
    t.integer  "shipment_index"
    t.integer  "company_id"
    t.decimal  "shipping_weight",              :precision => 6, :scale => 2
    t.datetime "delivered_date"
    t.decimal  "package_height",               :precision => 6, :scale => 2
    t.decimal  "package_width",                :precision => 6, :scale => 2
    t.decimal  "package_length",               :precision => 6, :scale => 2
    t.integer  "company_packaging_type_id"
    t.string   "aftership_token"
    t.integer  "shipment_checked_by"
    t.integer  "shipment_check_failed"
    t.string   "payment_information"
    t.string   "aftership_status"
    t.string   "aftership_signed_by"
    t.integer  "original_order_id"
    t.integer  "part_order_sequence",                                        :default => 0
  end

  add_index "orders", ["channel_id", "channel_order_id", "customer_id", "status"], :name => "order_headers_UK1", :unique => true

  create_table "packaging_types", :force => true do |t|
    t.string   "name"
    t.boolean  "custom",     :default => false
    t.boolean  "fedex",      :default => false
    t.boolean  "ad_hoc",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "pending_orders", :force => true do |t|
    t.text     "order_payload"
    t.string   "reason_pending"
    t.integer  "company_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "channel_id"
  end

  create_table "reports", :force => true do |t|
    t.string   "report_type"
    t.datetime "date_time"
    t.string   "report_file"
    t.string   "opened_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "company_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_destinations", :force => true do |t|
    t.integer  "company_id"
    t.string   "country_code"
    t.boolean  "item_weight_required"
    t.boolean  "item_county_of_origin_required"
    t.boolean  "harmonization_code_required"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "shipping_matrices", :force => true do |t|
    t.integer  "company_id"
    t.string   "country"
    t.string   "next_day",            :limit => 1
    t.decimal  "order_subtotal_from",              :precision => 15, :scale => 4
    t.decimal  "order_subtotal_to",                :precision => 15, :scale => 4
    t.decimal  "weight_from",                      :precision => 15, :scale => 4
    t.decimal  "weight_to",                        :precision => 15, :scale => 4
    t.decimal  "shipping_cost",                    :precision => 8,  :scale => 4
    t.integer  "shipping_service_id"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  create_table "shipping_methods", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "system_method"
    t.string   "ftp_server"
    t.string   "ftp_username"
    t.string   "ftp_password"
    t.string   "ftp_directory"
    t.string   "tracking_information"
    t.string   "tracking_url"
    t.string   "code"
    t.string   "default_weight"
    t.string   "aftership_code"
  end

  add_index "shipping_methods", ["name"], :name => "shipping_methods_UK1", :unique => true

  create_table "shipping_overrides", :force => true do |t|
    t.integer  "channel_id"
    t.string   "order_attribute"
    t.string   "qualifier"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_service_id"
  end

  create_table "shipping_service_account_details", :force => true do |t|
    t.integer  "shipping_service_id"
    t.integer  "stock_location_id"
    t.string   "account_number"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "shipping_services", :force => true do |t|
    t.integer  "shipping_method_id"
    t.string   "name"
    t.string   "integration_identifier"
    t.integer  "weight_required"
    t.integer  "customs_declaration_required"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tracked"
    t.string   "service_enhancement"
    t.integer  "active_flag",                    :default => 1
    t.string   "account_number"
    t.string   "service_reference"
    t.string   "royal_mail_service_enhancement"
    t.string   "royal_mail_service_format"
    t.string   "royal_mail_service_class"
    t.string   "royal_mail_service"
    t.integer  "company_id"
    t.integer  "location_id"
    t.string   "default_weight"
    t.string   "fedex_service_type"
    t.string   "fedex_package_type"
    t.string   "fedex_package_height"
    t.string   "fedex_package_width"
    t.string   "fedex_package_length"
    t.string   "dpd_service"
  end

  add_index "shipping_services", ["name", "location_id"], :name => "shipping_services_UK1", :unique => true

  create_table "status_rules", :force => true do |t|
    t.integer  "from_status_id"
    t.integer  "to_status_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "statuses", :force => true do |t|
    t.string   "status",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["status"], :name => "statuses_UK1", :unique => true

  create_table "stock_location_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "stock_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_location_users", ["user_id", "stock_location_id"], :name => "stock_location_user_UK1", :unique => true

  create_table "stock_locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reference"
    t.integer  "company_id"
    t.string   "ftp_server_address"
    t.string   "ftp_server_port"
    t.string   "ftp_username"
    t.string   "ftp_password_encrypted"
    t.string   "scale_ip_address"
    t.boolean  "enable_scale_integration"
    t.string   "serial_com_port"
    t.string   "serial_baud_rate"
    t.string   "serial_parity"
    t.string   "serial_csize"
    t.string   "serial_flow"
    t.string   "serial_stop"
    t.boolean  "stock_only"
  end

  add_index "stock_locations", ["name", "company_id"], :name => "stock_locations_UK1", :unique => true

  create_table "system_channel_settings", :force => true do |t|
    t.integer  "system_channel_id"
    t.string   "setting_1_text"
    t.string   "setting_1_enabled"
    t.string   "setting_2_text"
    t.string   "setting_2_enabled"
    t.string   "setting_3_text"
    t.string   "setting_3_enabled"
    t.string   "password_1_text"
    t.string   "password_1_enabled"
    t.string   "password_2_text"
    t.string   "password_2_enabled"
    t.string   "password_3_text"
    t.string   "password_3_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "setting_4_text"
    t.string   "setting_4_enabled"
  end

  add_index "system_channel_settings", ["system_channel_id"], :name => "system_channel_settings_UK1", :unique => true

  create_table "system_channels", :force => true do |t|
    t.string   "name",                                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "download_overlap_enabled", :default => false
  end

  add_index "system_channels", ["name"], :name => "system_channels_UK1", :unique => true

  create_table "system_settings", :force => true do |t|
    t.string   "setting_code"
    t.string   "setting_description"
    t.string   "setting_group"
    t.string   "value",               :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "setting_type",        :limit => 1
  end

  add_index "system_settings", ["setting_code"], :name => "System_Settings_UK1", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "default_landing_page"
    t.integer  "company_id"
    t.integer  "creating_user_id"
    t.integer  "current_location_id"
    t.string   "authentication_token"
    t.integer  "role_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
