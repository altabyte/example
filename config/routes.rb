OrderManager::Application.routes.draw do


  #api
  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: false) do
      # item api
      post '(:api_version/)import/submit' => 'import#submit'
      get '(:api_version/)export/export' => 'export#export'
    end
  end

  #orders
  get 'orders/shipment_check_datatable' => 'orders#shipment_check_datatable', :defaults => {:format => 'json'}
  get 'orders/get_pending_payload' => 'orders#get_pending_payload', :defaults => {:format => 'json'}
  post 'orders/retry_pending_orders' => 'orders#retry_pending_orders', :defaults => {:format => 'json'}
  match 'orders/pending_orders' => 'orders#pending_orders', :defaults => {:format => 'html'}
  match 'orders/shipment_check' => 'orders#shipment_check', :defaults => {:format => 'html'}
  get 'orders/do_shipment_check' => 'orders#do_shipment_check', :defaults => {:format => 'json'}
  match 'orders/reprint_rm_label' => 'orders#reprint_rm_label', :defaults => {:format => 'html'}
  post 'orders/update_order_status' => 'orders#update_order_status'
  match 'order_details/:id' => 'orders#order_details', :via => [:get]
  get 'orders/aftership_tracking/:id' => 'orders#aftership_tracking', :defaults => {:format => 'html'}
  resources :orders

  #picking
  match 'reports/pick_notes' => 'order_picks#render_pick_notes', :via => [:get]
  post 'order_picks/update_order_status' => 'order_picks#update_order_status'
  match 'order_picks/get_order' => 'order_picks#get_order'
  post 'order_picks/update_multiple_picks' => 'order_picks#update_multiple_picks'
  resources :order_picks do
    get :autocomplete_hs_code_description, :on => :collection
  end

  #weighing
  match 'order_weighing/get_order' => 'order_weighing#get_order'
  post 'order_weighing/update_weight' => 'order_weighing#update_weight'
  resources :order_weighing

  #shipping
  post 'order_shipments/update_order_status' => 'order_shipments#update_order_status'
  post 'order_shipments/change_shipping_method' => 'order_shipments#change_shipping_method'
  post 'order_shipments/ship_orders' => 'order_shipments#ship_orders'
  match 'order_shipments/get_order' => 'order_shipments#get_order'
  match 'dispatch_console' => 'order_shipments#dispatch_console'
  match 'update_tracking' => 'order_shipments#update_tracking'
  resources :order_shipments
  post 'shipping_destinations/destroy/:id' => 'shipping_destinations#destroy', :defaults => {:format => 'json'}
  resources :shipping_destinations
  post 'company_packaging_types/destroy/:id' => 'company_packaging_types#destroy', :defaults => {:format => 'json'}
  resources :company_packaging_types

  get "shipping_matrices/download_file" => 'shipping_matrices#download_file'
  post "shipping_matrices/import_file" => 'shipping_matrices#import_file'
  resources :shipping_matrices

  #settings and log
  match 'company_logs/clear' => 'company_logs#clear', :via => [:post]
  match 'company_logs/mark_as_read' => 'company_logs#mark_as_read', :via => [:post]
  post 'system_settings/:id/update' => 'system_settings#update', :defaults => {:format => 'html'}

  post 'companies/destroy/:id' => 'companies#destroy', :defaults => {:format => 'json'}
  post 'companies/:id/update_fedex_settings' => 'companies#update_fedex_settings', :defaults => {:format => 'html'}
  post 'companies/:id/update_basic_details' => 'companies#update_basic_details', :defaults => {:format => 'html'}
  get 'setup' => 'setup#index', :defaults => {:format => 'html'}


  get 'companies/clear_down_data' => 'companies#clear_down_data', :defaults => {:format => 'html'}
  get 'companies/status_change' => 'companies#status_change', :defaults => {:format => 'html'}
  get 'companies/:id/list_exchange_rates' => 'companies#list_exchange_rates'
  post 'companies/update_exchange_rate/:id' => 'companies#update_exchange_rate', :defaults => {:format => 'html'}
  get 'companies/edit_exchange_rate/:id' => 'companies#edit_exchange_rate', :defaults => {:format => 'html'}
  get 'companies/get_latest_exchange_rates' => 'companies#get_latest_exchange_rates', :defaults => {:format => 'json'}
  resources :company_logs
  resources :shipping_overrides
  get 'channel_shipping_services/list_new_services' => 'channel_shipping_services#list_new_services', :defaults => {:format => 'html'}
  post 'channel_shipping_services/save_new_services' => 'channel_shipping_services#save_new_services', :defaults => {:format => 'html'}
  resources :channel_shipping_services
  resources :channel_shipping_methods
  resources :system_settings
  resources :companies
  resources :statuses
  resources :channel_statuses
  resources :system_channels

  get 'channels/:id/edit_channel_status' => 'channels#edit_channel_status', :defaults => {:format => 'html'}
  get 'channels/:id/reload_log' => 'channels#reload_log', :defaults => {:format => 'html'}
  get 'channels/:id/list_channel_statuses' => 'channels#list_channel_statuses', :defaults => {:format => 'json'}
  post 'channels/destroy_channel_status/:id' => 'channels#destroy_channel_status', :defaults => {:format => 'json'}
  post 'channels/:id/update_channel_status' => 'channels#update_channel_status', :defaults => {:format => 'html'}
  post 'channels/destroy_shipping_service/:id' => 'channels#destroy_shipping_service', :defaults => {:format => 'json'}
  post 'channels/:id/update_shipping_service' => 'channels#update_shipping_service', :defaults => {:format => 'html'}
  get 'channels/:id/edit_shipping_service' => 'channels#edit_shipping_service', :defaults => {:format => 'html'}
  get 'channels/:id/list_channel_shipping_services' => 'channels#list_channel_shipping_services', :defaults => {:format => 'json'}
  post 'channels/:id/update' => 'channels#update', :defaults => {:format => 'html'}
  post 'channels/destroy/:id' => 'channels#destroy', :defaults => {:format => 'json'}
  resources :channels
  resources :fedex_settings

  #stock locations
  get 'stock_locations/:id/list_stock_location_users' => 'stock_locations#list_stock_location_users', :defaults => {:format => 'json'}
  get 'stock_locations/:id/new_stock_location_user' => 'stock_locations#new_stock_location_user', :defaults => {:format => 'html'}
  post 'stock_locations/create' => 'stock_locations#create', :defaults => {:format => 'html'}
  post 'stock_locations/create_stock_location_user' => 'stock_locations#create_stock_location_user', :defaults => {:format => 'html'}
  post 'stock_locations/delete_stock_location_user/:id' => 'stock_locations#delete_stock_location_user', :defaults => {:format => 'json'}
  post 'stock_locations/:id/update' => 'stock_locations#update', :defaults => {:format => 'html'}
  resources :stock_locations

  #shipping methods
  get 'shipping_methods/:id/list_shipping_services' => 'shipping_methods#list_shipping_services', :defaults => {:format => 'json'}
  get 'shipping_methods/edit_shipping_service/:id' => 'shipping_methods#edit_shipping_service', :defaults => {:format => 'html'}
  get 'shipping_methods/:id/new_shipping_service' => 'shipping_methods#new_shipping_service', :defaults => {:format => 'html'}
  post 'shipping_methods/:id/create_shipping_service' => 'shipping_methods#create_shipping_service', :defaults => {:format => 'html'}
  get 'shipping_methods/get_available_shipping_services' => 'shipping_methods#get_available_shipping_services', :defaults => {:format => 'html'}
  get 'shipping_methods/get_fedex_rate' => 'shipping_methods#get_fedex_rate', :defaults => {:format => 'json'}
  post 'shipping_methods/:id/update_shipping_service' => 'shipping_methods#update_shipping_service', :defaults => {:format => 'html'}
  post 'shipping_methods/delete_shipping_service/:id' => 'shipping_methods#delete_shipping_service', :defaults => {:format => 'json'}
  resources :shipping_methods

  #reports
  match 'last_report' => 'reports#last'
  resources :reports
  resources :fedex_shipments

  #customers and items
  resources :items
  get 'customers/:id/list_customer_addresses' => 'customers#list_customer_addresses', :defaults => {:format => 'json'}
  get 'customers/:id/list_orders' => 'customers#list_orders', :defaults => {:format => 'json'}
  post 'customers/:id/update_basic_details' => 'customers#update_basic_details', :defaults => {:format => 'html'}
  post 'customers/:id/update_customer_address' => 'customers#update_customer_address', :defaults => {:format => 'html'}
  get 'customers/:id/edit_customer_address' => 'customers#edit_customer_address', :defaults => {:format => 'html'}
  get 'customers/:id/edit_shipping_address' => 'customers#edit_shipping_address', :defaults => {:format => 'html'}
  get 'customers/postcode_search' => 'customers#postcode_search', :defaults => {:format => 'json'}
  get 'customers/postcode_get_by_id' => 'customers#postcode_get_by_id', :defaults => {:format => 'json'}
  resources :customers

  #users
  devise_for :users, :controllers => {:registrations => "users/registrations"}
  resources :users
  post 'users/:id/update_basic_details' => 'users#update_basic_details', :defaults => {:format => 'html'}
  post 'users/:id/delete_user' => 'users#delete_user', :defaults => {:format => 'html'}

  #home
  get 'home/check_for_new_orders' => 'home#check_for_new_orders', :defaults => {:format => 'json'}
  get 'home/information_panel' => 'home#information_panel', :defaults => {:format => 'html'}
  resources :home
  match "scale_test" => 'home#scale_test'
  match "dashboard" => 'home#dashboard'
  match "set_location" => 'home#set_location'
  match "release_notes" => 'home#release_notes'
  match "update_location" => 'home#update_location'
  match "/delayed_job" => DelayedJobWeb, :anchor => false

  #gets and matches
  root :to => 'home#index'

end
