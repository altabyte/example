require 'rexml/document'

module ExportPicks
  def self.export_pick(picks, order)
    begin
      require 'fileutils'
      file_path = Rails.root.join('export', order.channel.company.client_share, 'picks')
      FileUtils.mkdir_p file_path
      file = "#{file_path}/order_pick_#{order.id}-#{Time.now.strftime('%Y%m%d-%H%M%S')}.xml"
      unless File.exist?(file)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.OrderPicks {
            xml.ChannelOrderId order.channel_order_id
            xml.OrderId order.id
            xml.PickDateTime picks[0].created_at.localtime
            xml.PickLocation picks[0].stock_location.reference
            xml.PickedBy picks[0].user.name
            xml.Picks {
              picks.each do |pick_order|
                xml.Pick {
                  xml.SKU pick_order.item.sku
                  xml.QtyPicked pick_order.quantity_picked
                }
              end
            }
          }
        end
        File.open(file, "w") { |f| f << builder.to_xml }
      end
    rescue => exc
      return {:status => :failure, :message => exc}
    end
  end


end