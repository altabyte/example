module ShippingMethodsHelper

  def dpd_services_collection
    [
        [I18n.t('dpd_services.O'), 'O'],
        [I18n.t('dpd_services.S'), 'S'],
        [I18n.t('dpd_services.2'), '2'],
    ]
  end


end
