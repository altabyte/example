module ImportTracking
  def self.process_import_file(data, company_id=nil)
    result = true
    message = ''
    begin
      response_data = JSON.parse(data)
      success_resp = Order.process_aftership_data(response_data['msg'], company_id)
      message = success_resp[:message]
      result = success_resp[:success]
    rescue => exc
      result=false
      message=exc.to_s
      puts exc.to_s
    end
    {:success => result, :message => message}
  end
end