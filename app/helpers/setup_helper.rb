module SetupHelper

  def com_port_select
    ['COM1', 'COM2', 'COM3', 'COM4', 'COM5']
  end

  def baud_rate_select
    ['2400', '4800', '9600', '19200', '38400', '57600', '115200']
  end

  def parity_select
    [['NONE(0)', '0'], ['ODD(1)', '1'], ['EVEN(2)', '2']]
  end

  def csize_select
    [5, 6, 7, 8]
  end

  def flow_select
    [['NONE(0)', '0'], ['SOFTWARE(1)', '1'], ['HARDWARE(2)', '2']]
  end

  def stop_select
    [['1(0)', '0'], ['1.5(1)', '1'], ['2(2)', '2']]
  end

  def tail_log(channel)
    path = "#{Rails.root}/log/channels"
    log_path = "#{path}/#{channel.id}.log"
    `tail -n 50 #{log_path}`
  end

end
