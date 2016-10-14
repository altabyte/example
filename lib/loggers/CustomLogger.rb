class CustomLogger < Logger
  LINE_BREAK = '----------------------------------------------------------------------'
  NO_NEW_ORDERS = 'No new orders to process for:'
  DOWNLOADING_ORDERS = 'Downloading orders for:'
  PROCESSING_ORDER = 'Processing order:'
  FINISHED_DOWNLOADING = 'Finished downloading orders for:'

  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end