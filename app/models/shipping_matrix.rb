class ShippingMatrix < ActiveRecord::Base
  attr_accessible :company_id, :country, :next_day, :order_subtotal_from, :order_subtotal_to, :shipping_cost, :shipping_service_id, :weight_from, :weight_to

  belongs_to :shipping_service
  belongs_to :company

  require 'csv'


  def self.for_company(company_id)
    where(:company_id => company_id)
  end

  def self.by_country
    order(:country)
  end


  def self.get_matrix_file(company_id)
    records = ShippingMatrix.for_company(company_id).by_country
    csv = CSV.generate() do |csv|
      header_array = []
      header_array << 'country'
      header_array << 'next_day'
      header_array << 'order_subtotal_from'
      header_array << 'order_subtotal_to'
      header_array << 'weight_from'
      header_array << 'weight_to'
      header_array << 'shipping_cost'
      header_array << 'shipping_service'
      csv << header_array
      records.each do |record|
        record_array = []
        record_array << record.country
        record_array << record.next_day
        record_array << record.order_subtotal_from
        record_array << record.order_subtotal_to
        record_array << record.weight_from
        record_array << record.weight_to
        record_array << record.shipping_cost
        record_array << record.shipping_service.name
        csv << record_array
      end
    end
    csv
  end

  def self.import_matrix_file(company_id, file)
    error_messages = []
    begin
      ActiveRecord::Base.transaction do

        line_id = 1
        CSV.foreach(file.path, :headers => true, :encoding => 'ISO-8859-1') do |row|
          new_row = row.to_hash
          error_messages = validate_row(new_row, company_id)
          if error_messages.blank?
            line_id += 1
          else
            message = 'Import Error: Line' + line_id.to_s + ' ' + error_messages.join(',')
            return {:success => false, :message => message}
          end
        end

        ShippingMatrix.delete_all(:company_id => company_id)
        CSV.foreach(file.path, :headers => true, :encoding => 'ISO-8859-1') do |row|
          new_row = row.to_hash

          shipping_service = ShippingService.find_by_company_id_and_name(company_id, new_row['shipping_service'])
          shipping_service = ShippingService.where(:name => new_row['shipping_service']).where("company_id is null").first if shipping_service.nil?
          country = Country.find_country_by_alpha2(new_row['country'])
          country = Country.find_country_by_name(new_row['country']) if country.blank?
          country = Country.find_country_by_alpha3(new_row['country']) if country.blank?

          matrix = ShippingMatrix.new
          matrix.company_id = company_id
          matrix.country = country.alpha2
          matrix.next_day = new_row['next_day']
          matrix.order_subtotal_from = new_row['order_subtotal_from']
          matrix.order_subtotal_to = new_row['order_subtotal_to']
          matrix.weight_from = new_row['weight_from']
          matrix.weight_to = new_row['weight_to']
          matrix.shipping_cost = new_row['shipping_cost']
          matrix.shipping_service_id = shipping_service.id
          matrix.save!
        end
      end
      return {:success => true, :message => I18n.t('shipping_matrices.import.import_successful')}
    rescue => esc
      return {:success => false, :message => "#{I18n.t('shipping_matrices.import.import_error')}: #{esc.to_s}"}
    end
  end


  def self.is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def self.validate_row(new_row, company_id)
    error_message = []

    if new_row['shipping_service'].blank?
      error_message << 'shipping_service cannot be blank'
    else
      shipping_service = ShippingService.find_by_company_id_and_name(company_id, new_row['shipping_service'])
      shipping_service = ShippingService.where(:name => new_row['shipping_service']).where("company_id is null").first if shipping_service.nil?
      if shipping_service.blank?
        error_message << 'shipping_service cannot be found'
      elsif !shipping_service.active_flag
        error_message << 'shipping_service is not active'
      end
    end

    if new_row['country'].blank?
      error_message << 'country cannot be blank'
    else
      country = Country.find_country_by_alpha2(new_row['country'])
      country = Country.find_country_by_name(new_row['country']) if country.blank?
      country = Country.find_country_by_alpha3(new_row['country']) if country.blank?
      if country.blank?
        error_message << 'country cannot be found'
      end
    end

    if new_row['next_day'].present? and (new_row['next_day'] != 'Y' and new_row['next_day'] != 'N')
      error_message << 'next_day must be Y or N'
    end

    if new_row['order_subtotal_from'].blank?
      error_message << 'order_subtotal_from cannot be blank'
    elsif !is_a_number? new_row['order_subtotal_from']
      error_message << 'order_subtotal_from cannot be converted to a number'
    end

    if new_row['order_subtotal_to'].blank?
      error_message << 'order_subtotal_to cannot be blank'
    elsif !is_a_number? new_row['order_subtotal_to']
      error_message << 'order_subtotal_to cannot be converted to a number'
    end

    if new_row['weight_from'].blank?
      error_message << 'weight_from cannot be blank'
    elsif !is_a_number? new_row['weight_from']
      error_message << 'weight_from cannot be converted to a number'
    end

    if new_row['weight_to'].blank?
      error_message << 'weight_to cannot be blank'
    elsif !is_a_number? new_row['weight_to']
      error_message << 'weight_to cannot be converted to a number'
    end

    if new_row['shipping_cost'].blank?
      error_message << 'shipping_cost cannot be blank'
    elsif !is_a_number? new_row['shipping_cost']
      error_message << 'shipping_cost cannot be converted to a number'
    end
    return error_message
  end

end

