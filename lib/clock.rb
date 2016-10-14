require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork


#magento
every(10.minutes, 'Download Magento Orders') { Delayed::Job.enqueue(DelayedRake.new("magento:download_orders"), :queue => 'channel') }
every(1.hour, 'Update Missing Product Information') { Delayed::Job.enqueue(DelayedRake.new("magento:get_product_info"), :queue => 'channel') }
every(1.hour, 'Updating Magento fraud information') { Delayed::Job.enqueue(DelayedRake.new("magento:update_fraud_info"), :queue => 'channel') }

#amazon
every(15.minutes, 'Download Amazon Orders') { Delayed::Job.enqueue(DelayedRake.new("amazon:download_orders"), :queue => 'channel') }
#DISABLED UNTIL CONVERTED TO NEW IMPORT FORMAT every(1.day, 'Verify Amazon Order') { Delayed::Job.enqueue(VerifyAmazonOrdersJob.new(), :queue => 'channel')}

every(30.minutes, 'Download eBay Orders') { Delayed::Job.enqueue(DelayedRake.new("ebay:download_orders"), :queue => 'channel') }

#shipment
every(30.minutes, 'Process Tracking Information') { Delayed::Job.enqueue(ImportOrderTrackingJob.new(), :queue => "delivery") }
every(1.hour, 'Process Channel Updates') { Delayed::Job.enqueue(ShipOrderJob.new(), :queue => "channel") }
every(6.hours, 'Download Tracking Deliveries') { Delayed::Job.enqueue(DelayedRake.new("tracking:download"), :queue => 'channel') }
#every(20.minutes, 'Update Amazon') { Delayed::Job.enqueue(AmazonInventoryFeedJob.new(), :queue => 'channel')}

#excel clothing
every(1.day, 'Process Excel Inventory', :at => '07:30') { Delayed::Job.enqueue(DelayedRake.new("excel_clothing:process_stock"), :queue => 'channel') }