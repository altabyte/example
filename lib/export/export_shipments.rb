require 'rexml/document'

module ExportShipments
  def self.export_shipment(order, company, user, location)
    begin
      require 'fileutils'
      file_path = Rails.root.join('export', company.client_share, 'shipments')
      FileUtils.mkdir_p file_path
      file_path = "#{file_path}/order_shipment_#{order.id}.xml"
      unless File.exist?(file_path)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.Shipment {
            xml.ChannelOrderId order.channel_order_id
            xml.OrderId order.id
            xml.ShipmentDate Time.now.localtime
            xml.ShippedBy user.name
            xml.ShipmentLocation location.reference
            xml.ShippedItems {
              order.order_picks.each do |order_pick|
                xml.ShippedItem {
                  xml.SKU order_pick.item.sku
                  xml.QtyShipped order_pick.quantity_picked
                }
              end
            }
          }
        end
        File.open(file_path, "w") { |f| f << builder.to_xml }
      end
    rescue => exc
      return {:status => :failure, :message => exc}
    end
  end


end