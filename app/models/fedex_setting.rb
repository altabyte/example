class FedexSetting < ActiveRecord::Base
  attr_accessible :account_number, :company_id, :key, :meter, :mode, :password, :label_type

  belongs_to :company

  def self.get_rates(order, weight, fedex_data)
    require 'fedex'
    fedex_setting = FedexSetting.find_by_company_id(order.company_id)
    if fedex_setting.present?
      fedex = Fedex::Shipment.new(:key => fedex_setting.key,
                                  :password => fedex_setting.password,
                                  :account_number => fedex_setting.account_number,
                                  :meter => fedex_setting.meter,
                                  :mode => fedex_setting.mode

      )

      shipper = {:name => order.company.name,
                 :company => order.company.name,
                 :phone_number => order.company.telephone,
                 :address => [order.company.address_1, order.company.address_2],
                 :city => order.company.town,
                 :postal_code => order.company.post_code,
                 :country_code => order.company.country}

      #shipper = { :name => order.company.name,
      #            :company => order.company.name,
      #            :phone_number => order.company.telephone,
      #            :address => order.company.address_1,
      #            :city => order.company.town,
      #            :postal_code => order.company.post_code,
      #            :country_code => order.company.country }

      recipient = {:name => order.customer.full_name.gsub(',', ' '),
                   :company => (order.shipping_address.company.gsub(',', ' ') rescue ''),
                   :phone_number => (order.shipping_address.telephone rescue ''),
                   :address => (order.shipping_address.address_1.gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(',', ' ') rescue ""),
                   :city => (order.shipping_address.town.gsub(',', ' ') rescue ""),

                   :postal_code => (order.shipping_address.post_code.gsub(',', ' ') rescue ""),
                   :country_code => (order.shipping_address.country.gsub(',', ' ') rescue ""),
                   :residential => (order.shipping_address.company.present? ? 'true' : 'false')}

      #:state => (order.shipping_address.county.gsub(',', ' ') rescue ""),

      #recipient = { :name => "Recipient",
      #              :company => "Company",
      #              :phone_number => "555-555-5555",
      #              :address => "Main Street",
      #              :city => "Franklin Park",
      #              :state => "IL",
      #              :postal_code => "60131",
      #              :country_code => "US",
      #              :residential => "false" }

      packages = []
      if fedex_data[:package_type] == 'YOUR_PACKAGING'
        packages << {
            :weight => {:units => "KG", :value => weight.to_i},
            :dimensions => {:length => fedex_data[:package_length].to_i, :width => fedex_data[:package_width].to_i, :height => fedex_data[:package_height].to_i, :units => "CM"}
        }
      else
        packages << {
            :weight => {:units => "KG", :value => weight.to_i}
        }
      end


      shipping_options = {
          :packaging_type => fedex_data[:package_type],
          :drop_off_type => "REGULAR_PICKUP"
      }


      rate = fedex.rate(:shipper => shipper,
                        :recipient => recipient,
                        :packages => packages,
                        :shipping_options => shipping_options,
                        :debug => true)


      rate
    end
  end

  def self.ship_order(order, location)

    begin

      fedex_setting = FedexSetting.find_by_company_id(order.company_id)
      if fedex_setting.present?
        fedex = Fedex::Shipment.new(:key => fedex_setting.key,
                                    :password => fedex_setting.password,
                                    :account_number => fedex_setting.account_number,
                                    :meter => fedex_setting.meter,
                                    :mode => fedex_setting.mode

        )

        shipper = {:name => order.company.name,
                   :company => order.company.name,
                   :phone_number => order.company.telephone.gsub(/[^0-9a-z ]/i, ''),
                   :address => [order.company.address_1, order.company.address_2],
                   :city => order.company.town,
                   :postal_code => order.company.post_code,
                   :country_code => order.company.country}

        cust_addr_1 = order.shipping_address.address_1.gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(',', ' ') rescue nil
        cust_addr_2 = order.shipping_address.address_2.gsub(/([^\n])\n([^\n])/, '\1 \2').gsub(',', ' ') rescue nil

        recipient = {:name => order.customer.full_name.gsub(',', ' '),
                     :company => (order.shipping_address.company.gsub(',', ' ') rescue ''),
                     :phone_number => (order.shipping_address.telephone.gsub(/[^0-9a-z ]/i, '') rescue ''),
                     :address => ([cust_addr_1, cust_addr_2]),
                     :city => (order.shipping_address.town.gsub(',', ' ') rescue ""),

                     :postal_code => (order.shipping_address.post_code.gsub(',', ' ') rescue ""),
                     :country_code => (order.shipping_address.country.gsub(',', ' ') rescue ""),
                     :residential => (order.shipping_address.company.present? ? 'true' : 'false')}

        if order.shipping_address.country == 'US'
          recipient[:state] = order.shipping_address.county rescue ""
        end

        if order.company_packaging_type.packaging_type.custom or order.company_packaging_type.packaging_type.ad_hoc
          pkg_type = 'YOUR_PACKAGING'
        else
          pkg_type = order.company_packaging_type.packaging_type.name
        end

        fedex_data = {
            :package_type => pkg_type,
            :package_length => order.package_length,
            :package_width => order.package_width,
            :package_height => order.package_height
        }

        weight = order.shipping_weight


        packages = []
        if fedex_data[:package_type] == 'YOUR_PACKAGING'
          packages << {
              :weight => {:units => "KG", :value => weight.to_i},
              :dimensions => {:length => fedex_data[:package_length].to_i, :width => fedex_data[:package_width].to_i, :height => fedex_data[:package_height].to_i, :units => "CM"}
          }
        else
          packages << {
              :weight => {:units => "KG", :value => weight.to_i}
          }
        end


        shipping_options = {
            :packaging_type => fedex_data[:package_type],
            :drop_off_type => "REGULAR_PICKUP"
        }

        customs_value = {:currency => "UKL",
                         :amount => order.subtotal}

        duties_payment = {:payment_type => "RECIPIENT"}

        commodities = []
        avg_weight = weight / order.order_details.count
        order.order_details.each do |order_item|
          puts order_item
          commodities << {:name => order_item.item.name,
                          :number_of_pieces => '1',
                          :description => order_item.item.name,
                          :country_of_manufacture => (order_item.item.country_code.present? ? order_item.item.country_code : "US"),
                          :harmonized_code => (order_item.item.harmonization_code rescue "6103320000"),
                          :weight => {:units => "KG", :value => order_item.item.item_weight},
                          :quantity => order_item.quantity_ordered,
                          :quantity_units => 'EA',
                          :unit_price => {:currency => "UKL", :amount => order_item.unit_price},
                          :customs_value => {:currency => "UKL", :amount => (order_item.unit_price * order_item.quantity_ordered)}}
        end


        #customs_clearance = {:broker => broker,
        #                     :clearance_brokerage => clearance_brokerage,
        #                     :importer_of_record => importer_of_record,
        #                     :recipient_customs_id => recipient_customs_id,
        #                     :duties_payment => duties_payment,
        #                     :customs_value => customs_value,
        #                     :commodities => commodities }
        customs_clearance = {
            :duties_payment => duties_payment,
            :customs_value => customs_value,


            :commodities => commodities
        }


        label_spec = {
            :label_stock_type => (fedex_setting.label_type rescue "PAPER_4X6")
        }


        fedex_file_name = "#{Rails.root}/#{order.id}_fedex_label.pdf"

        label = fedex.label(:filename => fedex_file_name,
                            :shipper => shipper,
                            :recipient => recipient,
                            :packages => packages,
                            :service_type => order.actual_shipping_service.name,
                            :shipping_options => shipping_options,
                            :customs_clearance => customs_clearance,
                            :label_specification => label_spec
        )

        if File.exist?(fedex_file_name) and label.tracking_number
          label_file = File.open(fedex_file_name)
          shipment = FedexShipment.find_or_create_by_order_id(order.id)
          shipment.label = label_file
          shipment.save!

          File.delete(fedex_file_name)

          order.tracking_details = label.tracking_number
          order.save!
          order.update_status(Order::STATUS_DISPATCHED)

        end


      end
    rescue => exc
      order.shipment_error = exc.to_s
      order.update_status(Order::STATUS_WEIGHED)
      order.save!
      current_location = StockLocation.find(location)
      CompanyLog.create(
          :company_id => order.channel.company_id,
          :log_level => 'ERROR',
          :date_timestamp => DateTime.now(),
          :message => ("Fedex Shipment Failed @ #{current_location.name}: Error returned from Fedex API #{exc.to_s} Order ID:#{order.id}")
      )
    end
  end

  #duties_payment = {:payment_type => "SENDER",
  #                  :payor => {:account_number => "123456",
  #                             :country_code => "US" } }
  #
  #customs_value = {:currency => "USD",
  #                 :amount => "200" }
  #commodities = []
  #commodities << {:name => "Cotton Coat",
  #                :number_of_pieces => "2",
  #                :description => "Cotton Coat",
  #                :country_of_manufacture => "US",
  #                :harmonized_code => "6103320000",
  #                :weight => {:units => "LB", :value => "2"},
  #                :quantity => "3",
  #                :unit_price => {:currency => "USD", :amount => "50" },
  #                :customs_value => {:currency => "USD", :amount => "150" } }
  #
  #commodities << {:name => "Poster",
  #                :number_of_pieces => "1",
  #                :description => "Paper Poster",
  #                :country_of_manufacture => "US",
  #                :harmonized_code => "4817100000",
  #                :weight => {:units => "LB", :value => "0.2"},
  #                :quantity => "3",
  #                :unit_price => {:currency => "USD", :amount => "50" },
  #                :customs_value => {:currency => "USD", :amount => "150" } }
  #
  #customs_clearance = {:broker => broker,
  #                     :clearance_brokerage => clearance_brokerage,
  #                     :importer_of_record => importer_of_record,
  #                     :recipient_customs_id => recipient_customs_id,
  #                     :duties_payment => duties_payment,
  #                     :customs_value => customs_value,
  #                     :commodities => commodities }


end
