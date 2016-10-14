class OrderFraudScore < ActiveRecord::Base
  belongs_to :self
  #
  #def get_cv2result
  #  this_cv2result = ""
  #  if self.cv2result.present?
  #    case self.cv2result
  #      when "MATCHED"
  #        this_cv2result =  image_tag('fraud_icons\icon-shield-check.png', :title => "CV2: MATCHED", :alt => "CV2: MATCHED")
  #      when "NOTPROVIDED"
  #        this_cv2result =  image_tag('fraud_icons\icon-shield-outline.png', :title => "CV2: NOTPROVIDED", :alt => "CV2: NOTPROVIDED")
  #    end
  #  end
  #  return this_cv2result
  #end
  #
  #def get_address_result
  #  if self.address_result.present?
  #    case self.address_result
  #      when "MATCHED"
  #        get_address_result = image_tag('fraud_icons\icon-shield-check.png', :title => "ADD: MATCHED", :alt => "ADD: MATCHED")
  #      when "NOTMATCHED"
  #        get_address_result = image_tag('fraud_icons\icon-shield-cross.png', :title => "ADD: NOTMATCHED", :alt => "ADD: NOTMATCHED")
  #      when "NOTCHECKED"
  #        get_address_result = image_tag('fraud_icons\icon-shield-outline.png', :title => "ADD: NOTCHECKED", :alt => "ADD: NOTCHECKED")
  #      when "NOTPROVIDED"
  #        get_address_result = image_tag('fraud_icons\icon-shield-zebra.png', :title => "ADD: NOTPROVIDED", :alt => "ADD: NOTPROVIDED")
  #    end
  #  end
  #end
  #
  #
  #def get_postcode_result
  #  if self.postcode_result.present?
  #    case self.postcode_result
  #      when "MATCHED"
  #        get_postcode_result = image_tag('fraud_icons\icon-shield-check.png', :title => "PC: MATCHED", :alt => "PC: MATCHED")
  #      when "NOTMATCHED"
  #        get_postcode_result = image_tag('fraud_icons\icon-shield-cross.png', :title => "PC: NOTMATCHED", :alt => "PC: NOTMATCHED")
  #      when "NOTCHECKED"
  #        get_postcode_result = image_tag('fraud_icons\icon-shield-outline.png', :title => "PC: NOTCHECKED", :alt => "PC: NOTCHECKED")
  #      when "NOTPROVIDED"
  #        get_postcode_result = image_tag('fraud_icons\icon-shield-zebra.png', :title => "PC: NOTPROVIDED", :alt => "PC: NOTPROVIDED")
  #    end
  #  end
  #end
  #
  #def get_threed_secure_status
  #  if self.threed_secure_status.present?
  #    case self.threed_secure_status
  #      when "OK"
  #        get_threed_secure_status = image_tag('fraud_icons\icon-shield-check.png', :title => "3D: OK", :alt => "OK")
  #      when "NOTAVAILABLE"
  #        get_threed_secure_status = image_tag('fraud_icons\icon-shield-zebra.png', :title => "3D: NOTAVAILABLE", :alt => "3D: NOTAVAILABLE")
  #      when "NOTCHECKED"
  #        get_threed_secure_status = image_tag('fraud_icons\icon-shield-outline.png', :title => "3D: NOTCHECKED", :alt => "3D: NOTCHECKED")
  #      when "NOTAUTHED"
  #        get_threed_secure_status = image_tag('fraud_icons\icon-shield-cross.png', :title => "3D: NOTAUTHED", :alt => "3D: NOTAUTHED")
  #      when "ATTEMPTONLY"
  #        get_threed_secure_status = image_tag('fraud_icons\icon-shield-question.png', :title => "3D: ATTEMPTONLY", :alt => "3D: ATTEMPTONLY")
  #    end
  #  end
  #end
  #
  #
  #def get_thirdman_action
  #  if self.thirdman_action.present?
  #    case self.thirdman_action
  #      when "OK"
  #        get_thirdman_action = image_tag('fraud_icons\icon-shield-check.png', :title => "3RDMan: OK Score:" + self.thirdman_score.to_s, :alt => "3RDMan: OK Score:" + self.thirdman_score.to_s)
  #      when "NOTMATCHED"
  #        get_thirdman_action = image_tag('fraud_icons\icon-shield-cross.png', :title => "3RDMan: NOTMATCHED Score:" + self.thirdman_score.to_s, :alt => "3RDMan: NOTMATCHED Score:" + self.thirdman_score.to_s)
  #      when "NORESULT"
  #        get_thirdman_action = image_tag('fraud_icons\icon-shield-cross.png', :title => "3RDMan: NORESULT Score:" + self.thirdman_score.to_s, :alt => "3RDMan: NORESULT Score:" + self.thirdman_score.to_s)
  #      when "NOTCHECKED"
  #        get_thirdman_action = image_tag('fraud_icons\icon-shield-outline.png', :title => "3RDMan: NOTCHECKED Score:" + self.thirdman_score.to_s, :alt => "3RDMan: NOTCHECKED Score:" + self.thirdman_score.to_s)
  #    end
  #  end
  #end

end
