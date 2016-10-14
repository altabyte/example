require 'barby'
require 'barby/outputter/prawn_outputter'
require 'barby/barcode/code_39'
class ShipmentNote < Prawn::Document

  def self.shipment_report(orders, current_user, context_company)
    file = "shipment.pdf"
    Prawn::Document.generate(file, {:bottom_margin => 0, :page_size => "A4"}) do |pdf|
      shipping_note(orders, pdf, context_company)
    end
    report = Report.add_report(Report::ORDER_SHIPMENT_NOTE, file, current_user)
    report

  end

  def self.shipping_note(orders, pdf, context_company)
    len = orders.length
    orders.each_with_index do |order, index|
      puts "Generating Shipment PDF document."

      initial_y = pdf.cursor
      initialmove_y = 5
      address_x = 35

      label_cord = SystemSetting.check_setting('integrated_label_start_cord', 200, context_company).to_i

      customer_label_y = label_cord
      customer_label_x = 30
      small_address_x = 130

      return_label_y = label_cord
      return_label_x = 300
      invoice_header_x = 300
      lineheight_y = 14
      font_size = 9

      pdf.move_down initialmove_y
      pdf.font "Helvetica"
      pdf.font_size 12
      pdf.move_down 10
      barcode = Barby::Code39.new("#{order.id.to_s.rjust(10, '0')}")
      barcode.annotate_pdf(pdf, :height => 30, :x => 250, :y => pdf.cursor)

      pdf.move_down 40

      barcode = Barby::Code39.new("#{order.channel_order_id.to_s}")
      barcode.annotate_pdf(pdf, :height => 20, :x => 250, :y => pdf.cursor)

      barcode = Barby::Code39.new("#{order.id.to_s.rjust(10, '0')}")

      pdf.move_down 20

      pdf.text_box "#{I18n.t('reports.order_reports.shipment.title')}", :at => [invoice_header_x, pdf.cursor], :style => :bold, :size => 15
      pdf.move_down lineheight_y
      pdf.move_down lineheight_y
      pdf.move_down lineheight_y

      pdf.text_box "#{I18n.t('reports.order_reports.shipment.order_id')}: #{order.id}", :at => [invoice_header_x, pdf.cursor]
      pdf.move_down lineheight_y
      pdf.text_box "#{I18n.t('reports.order_reports.shipment.order_date')}: #{I18n.l(order.order_date)}", :at => [invoice_header_x, pdf.cursor]
      pdf.move_down lineheight_y

      pdf.text_box "#{I18n.t('reports.order_reports.shipment.source')}: #{order.channel.name}", :at => [invoice_header_x, pdf.cursor]
      pdf.move_down lineheight_y
      source_y = pdf.cursor

      pdf.text_box "#{I18n.t('reports.order_reports.shipment.order_reference')}: #{order.channel_order_id}", :at => [invoice_header_x, pdf.cursor]
      pdf.move_down lineheight_y

      if order.channel_shipping_service.useable_text.present?
        courier = "#{order.channel_shipping_service.useable_text}"
        pdf.text_box "#{I18n.t('reports.order_reports.shipment.shipping_service')}: #{courier}", :at => [invoice_header_x, pdf.cursor]
        pdf.move_down lineheight_y
      end

      if order.payment_information.present?
        pdf.text_box "#{I18n.t('reports.order_reports.shipment.payment_method')}: #{order.payment_information}", :at => [invoice_header_x, pdf.cursor]
        pdf.move_down lineheight_y
      end

      pdf.font_size font_size

      pdf.text_box "#{I18n.t('reports.order_reports.shipment.customer')}:", :at => [address_x, pdf.cursor], :style => :bold
      pdf.move_down lineheight_y
      pdf.text_box order.shipping_address.address_block, :at => [address_x, pdf.cursor]


      last_measured_y = pdf.cursor

      if SystemSetting.check_setting('sn_with_integrated_labels', true, context_company)
        #customer label

        pdf.font_size = 12
        pdf.move_cursor_to customer_label_y
        barcode.annotate_pdf(pdf, :height => 20, :x => customer_label_x, :y => (pdf.cursor - 15))
        pdf.move_down 20
        pdf.text_box ("##{order.channel_order_id}"), :at => [customer_label_x, pdf.cursor]
        pdf.move_down lineheight_y
        pdf.text_box order.shipping_address.address_block, :at => [customer_label_x, pdf.cursor]
        pdf.move_down (lineheight_y * 7)

        #return address
        pdf.move_cursor_to return_label_y
        barcode.annotate_pdf(pdf, :height => 20, :x => return_label_x, :y => (pdf.cursor - 15))
        pdf.move_down 20
        pdf.text_box "#{I18n.t('reports.order_reports.shipment.return_address')}:", :at => [return_label_x, pdf.cursor], :style => :bold
        pdf.move_down lineheight_y
        pdf.text_box order.channel.address_block, :at => [return_label_x, pdf.cursor]
        pdf.move_down (lineheight_y * 7)


        pdf.font_size = font_size
        pdf.move_cursor_to last_measured_y
      end


      #header logo and address

      pdf.move_cursor_to pdf.bounds.height

      if order.channel.logo.present?
        pdf.image order.channel.logo.path, :position => :left, :fit => [100, 100]
      elsif order.channel.company.logo.present?
        pdf.image order.channel.company.logo.path, :position => :left, :fit => [100, 100]
      end

      pdf.move_cursor_to pdf.bounds.height
      pdf.font_size = 7
      pdf.text_box order.channel.address_block, :at => [small_address_x, pdf.cursor]
      pdf.move_down (lineheight_y * 7)

      pdf.font_size = font_size
      pdf.move_cursor_to last_measured_y

      pdf.move_down (lineheight_y * 7)

      order_pick_data = [
          [I18n.t('reports.order_reports.shipment.table.sku'),
           I18n.t('reports.order_reports.shipment.table.description'),
           I18n.t('reports.order_reports.shipment.table.qty_ordered'),
           I18n.t('reports.order_reports.shipment.table.qty')
          ]
      ]

      total_items = 0

      order.order_details.each do |order_detail|
        puts "SKU: #{order_detail.item.sku}"
        qty = order_detail.quantity_ordered - order_detail.order_picks.sum(:quantity_picked)
        order_pick_data << [order_detail.item.sku,
                            order_detail.item.name, order_detail.quantity_ordered,
                            qty
        ]
        total_items += qty
      end

      puts "Generating table"
      begin
        pdf.table(order_pick_data, :width => pdf.bounds.width) do
          style(row(1..-1).columns(0..-1), :padding => [4, 5, 4, 5], :borders => [:bottom], :border_color => 'dddddd')
          style(row(0), :background_color => 'e9e9e9', :border_color => 'dddddd', :font_style => :bold)
          style(row(0).columns(0..-1), :borders => [:top, :bottom])
          style(row(0).columns(0), :borders => [:top, :left, :bottom])
          style(row(0).columns(-1), :borders => [:top, :right, :bottom])
          style(row(-1), :border_width => 2)
          style(column(2..-1), :align => :right)
          style(columns(0), :width => 100)
          style(columns(1), :width => 260)
        end
      rescue
        puts "Error Generating table"
      end
      puts "Completed Generating table"
      pdf.move_down lineheight_y

      pdf.text_box "#{I18n.t('reports.order_reports.shipment.total_items')}:", :at => [(pdf.bounds.width-200), pdf.cursor], :style => :bold, :align => :right, :width => 100
      pdf.text_box total_items.to_s, :at => [(pdf.bounds.width-105), pdf.cursor], :style => :bold, :align => :right, :width => 100
      pdf.move_down lineheight_y

      if SystemSetting.check_setting('print_terms_with_pick_notes', true, context_company)
        if order.company.terms_pdf.present? or order.channel.terms_pdf.present?
          template = order.channel.terms_pdf
          template = order.company.terms_pdf if template.blank?
          pdf.start_new_page(:template => template.path)
        end
      end

      if index+1 != len
        pdf.start_new_page
      end
    end
  end

end

