require 'barby'
require 'barby/outputter/prawn_outputter'
require 'barby/barcode/code_39'
class PickNote < Prawn::Document


  def self.picking_report(orders, current_user, context_company)
    file = "pick_notes.pdf"
    Prawn::Document.generate(file, :page_size => "A4", :page_layout => :landscape) do |pdf|
      pdf.autoprint
      puts "Generating Picking Notes PDF document."

      initialmove_y = 5
      invoice_header_x = 5
      lineheight_y = 14
      font_size = 9

      pdf.move_down initialmove_y
      pdf.font "Helvetica"
      pdf.font_size 12

      pdf.text_box "#{I18n.t('reports.order_reports.pick_note.title')}", :at => [invoice_header_x, pdf.cursor], :style => :bold, :size => 15
      pdf.text_box "#{I18n.t('reports.order_reports.pick_note.location')}: #{current_user.stock_location.name}", :at => [invoice_header_x + 100, pdf.cursor], :style => :bold, :size => 12
      pdf.text_box "#{I18n.t('reports.order_reports.pick_note.printed_date')}: #{I18n.l(DateTime.now())}", :at => [invoice_header_x + 350, pdf.cursor], :style => :bold, :size => 12
      pdf.text_box "#{I18n.t('reports.order_reports.pick_note.printed_by')}: #{current_user.name}", :at => [invoice_header_x + 600, pdf.cursor], :style => :bold, :size => 12

      pdf.move_down 20

      pdf.font_size font_size
      last_measured_y = pdf.cursor

      total_items = 0
      if SystemSetting.check_setting('paper_pick_info', true, context_company)
        order_pick_data = [
            [
                I18n.t('reports.order_reports.pick_note.table.order_id'),
                I18n.t('reports.order_reports.pick_note.table.sku'),
                I18n.t('reports.order_reports.pick_note.table.description'),
                I18n.t('reports.order_reports.pick_note.table.qty'),
                I18n.t('reports.order_reports.pick_note.table.qty_picked'),
                I18n.t('reports.order_reports.pick_note.table.picked_by')
            ]
        ]
      else
        order_pick_data = [
            [
                I18n.t('reports.order_reports.pick_note.table.order_id'),
                I18n.t('reports.order_reports.pick_note.table.sku'),
                I18n.t('reports.order_reports.pick_note.table.description'),
                I18n.t('reports.order_reports.pick_note.table.qty')
            ]
        ]
      end


      orders.each_with_index do |order, index|
        if SystemSetting.check_setting('paper_pick_info', true, context_company)
          order.order_details.each do |order_detail|
            puts "SKU: #{order_detail.item.sku}"
            qty = order_detail.quantity_ordered - order_detail.order_picks.sum(:quantity_picked)
            order_pick_data << [order.id, order_detail.item.sku,
                                order_detail.item.name,
                                qty,
                                "", ""]
            total_items += qty
          end
        else
          order.order_details.each do |order_detail|
            puts "SKU: #{order_detail.item.sku}"
            qty = order_detail.quantity_ordered - order_detail.order_picks.sum(:quantity_picked)
            order_pick_data << [order.id, order_detail.item.sku,
                                order_detail.item.name,
                                qty]
            total_items += qty
          end

        end

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
          style(column(3..-1), :align => :right)
          style(column(3), :width => 30)
          style(columns(1), :width => 200)
          style(columns(2), :width => 300)
          style(columns(0), :width => 80)
        end
      rescue => exc
        puts "Error Generating table - #{exc.to_s}"
      end
      puts "Completed Generating table"
      pdf.move_down lineheight_y

      pdf.text_box "#{I18n.t('reports.order_reports.pick_note.total_items')}:", :at => [(pdf.bounds.width-200), pdf.cursor], :style => :bold, :align => :right, :width => 100
      pdf.text_box total_items.to_s, :at => [(pdf.bounds.width-105), pdf.cursor], :style => :bold, :align => :right, :width => 100
      pdf.move_down lineheight_y
      pdf.move_down lineheight_y
      pdf.move_down lineheight_y

      if SystemSetting.check_setting('print_delivery_note_with_pick_list', true, context_company)
        pdf.start_new_page(:bottom_margin => 0, :layout => :portrait)
        ShipmentNote.shipping_note(orders, pdf, context_company)
      end

    end
    report = Report.add_report(Report::ORDER_PICK_NOTE, file, current_user)
    report
  end

end
