class UpdateSystemSettingGroups < ActiveRecord::Migration
  def change

    SystemSetting.update_all('setting_group = "Order Processing"', 'setting_group != "Stock"')


  end
end
