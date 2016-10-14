module OrdersHelper

  def sagepay_display(orders)
    #fraud results
    cv2result = ""
    if orders.cv2result.present?
      case orders.cv2result
        when "MATCHED"
          cv2result = image_tag('fraud_icons\icon-shield-check.png', :title => "CV2: MATCHED", :alt => "CV2: MATCHED")
        when "NOTPROVIDED"
          cv2result = image_tag('fraud_icons\icon-shield-outline.png', :title => "CV2: NOTPROVIDED", :alt => "CV2: NOTPROVIDED")
      end
    end
    address_result = ""
    if orders.address_result.present?
      case orders.address_result
        when "MATCHED"
          address_result = image_tag('fraud_icons\icon-shield-check.png', :title => "ADD: MATCHED", :alt => "ADD: MATCHED")
        when "NOTMATCHED"
          address_result = image_tag('fraud_icons\icon-shield-cross.png', :title => "ADD: NOTMATCHED", :alt => "ADD: NOTMATCHED")
        when "NOTCHECKED"
          address_result = image_tag('fraud_icons\icon-shield-outline.png', :title => "ADD: NOTCHECKED", :alt => "ADD: NOTCHECKED")
        when "NOTPROVIDED"
          address_result = image_tag('fraud_icons\icon-shield-zebra.png', :title => "ADD: NOTPROVIDED", :alt => "ADD: NOTPROVIDED")
      end
    end

    postcode_result = ""
    if orders.postcode_result.present?
      case orders.postcode_result
        when "MATCHED"
          postcode_result = image_tag('fraud_icons\icon-shield-check.png', :title => "PC: MATCHED", :alt => "PC: MATCHED")
        when "NOTMATCHED"
          postcode_result = image_tag('fraud_icons\icon-shield-cross.png', :title => "PC: NOTMATCHED", :alt => "PC: NOTMATCHED")
        when "NOTCHECKED"
          postcode_result = image_tag('fraud_icons\icon-shield-outline.png', :title => "PC: NOTCHECKED", :alt => "PC: NOTCHECKED")
        when "NOTPROVIDED"
          postcode_result = image_tag('fraud_icons\icon-shield-zebra.png', :title => "PC: NOTPROVIDED", :alt => "PC: NOTPROVIDED")
      end
    end

    threed_secure_status = ""
    if orders.threed_secure_status.present?
      case orders.threed_secure_status
        when "OK"
          threed_secure_status = image_tag('fraud_icons\icon-shield-check.png', :title => "3D: OK", :alt => "3D: OK")
        when "NOTAVAILABLE"
          threed_secure_status = image_tag('fraud_icons\icon-shield-zebra.png', :title => "3D: NOTAVAILABLE", :alt => "3D: NOTAVAILABLE")
        when "NOTCHECKED"
          threed_secure_status = image_tag('fraud_icons\icon-shield-outline.png', :title => "3D: NOTCHECKED", :alt => "3D: NOTCHECKED")
        when "NOTAUTHED"
          threed_secure_status = image_tag('fraud_icons\icon-shield-cross.png', :title => "3D: NOTAUTHED", :alt => "3D: NOTAUTHED")
        when "ATTEMPTONLY"
          threed_secure_status = image_tag('fraud_icons\icon-shield-question.png', :title => "3D: ATTEMPTONLY", :alt => "3D: ATTEMPTONLY")
        when "ERROR"
          threed_secure_status = image_tag('fraud_icons\icon-shield-question.png', :title => "3D: ERROR", :alt => "3D: ERROR")
      end
    end

    thirdman_action = ""
    if orders.thirdman_action.present?
      case orders.thirdman_action
        when "OK"
          thirdman_action = image_tag('fraud_icons\icon-shield-check.png', :title => "3rdMan: OK Score:" + orders.thirdman_score.to_s, :alt => "3rdMan: OK Score:" + orders.thirdman_score.to_s)
        when "REJECT"
          thirdman_action = image_tag('fraud_icons\icon-shield-cross.png', :title => "3rdMan: REJECT Score:" + orders.thirdman_score.to_s, :alt => "3rdMan: REJECT Score:" + orders.thirdman_score.to_s)
        when "NORESULT"
          thirdman_action = image_tag('fraud_icons\icon-shield-cross.png', :title => "3rdMan: NORESULT Score:" + orders.thirdman_score.to_s, :alt => "3rdMan: NORESULT Score:" + orders.thirdman_score.to_s)
        when "NOTCHECKED"
          thirdman_action = image_tag('fraud_icons\icon-shield-outline.png', :title => "3rdMan: NOTCHECKED Score:" + orders.thirdman_score.to_s, :alt => "3rdMan: NOTCHECKED Score:" + orders.thirdman_score.to_s)
      end
    end

    {
        :cv2result => cv2result,
        :address_result => address_result,
        :postcode_result => postcode_result,
        :threed_secure_status => threed_secure_status,
        :thirdman_action => thirdman_action
    }
  end

  def aftership_checkpoints_to_table(checkpoints)
    checkpoints = checkpoints.reverse

    html = '<table class="table table-striped tracking_details_table">'

    checkpoint_count = checkpoints.length

    checkpoints.each_with_index do |checkpoint, index|
      html += '<tr>'
      datetime = Time.parse(checkpoint['checkpoint_time'])
      html += "<td class='track-detail-datetime'>#{datetime.to_date()}<div class='muted'>#{datetime.to_s(:time) rescue ''}</div></td>"

      if checkpoint_count == index + 1
        html += "<td class='track-detail-status icon down'><div class='track-detail-status-icon #{checkpoint['tag'].to_s.downcase}'></div></td>"
      else
        html += "<td class='track-detail-status icon'><div class='track-detail-status-icon #{checkpoint['tag'].to_s.downcase}'></div></td>"

      end
      html += "<td class='info'>#{checkpoint['message']}<div class='muted'>#{checkpoint['country_name']}</div></td>"
      html += '</tr>'

    end


    html += '<table>'
    html


  end

end
